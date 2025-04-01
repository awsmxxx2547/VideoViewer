#include "../include/video.h"
#include "../include/sdl.h"
#include <libavutil/mem.h>
#include <stdint.h>

int init_video(const char *filename, AVFormatContext **format_context, 
               AVCodecContext **video_codec_context, int *video_stream_index,
               AVCodecContext **audio_codec_context, int *audio_stream_index)
{
    *format_context = avformat_alloc_context();
    if (!*format_context) {
        fprintf(stderr, "Could not allocate format context\n");
        return -1;
    }

    if (avformat_open_input(format_context, filename, NULL, NULL) != 0) {
        fprintf(stderr, "Could not open input file '%s'\n", filename);
        avformat_free_context(*format_context);
        return -1;
    }

    if (avformat_find_stream_info(*format_context, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        avformat_close_input(format_context);
        return -1;
    }

    for (unsigned int i = 0; i < (*format_context)->nb_streams; i++) {
        AVCodecParameters *codecpar = (*format_context)->streams[i]->codecpar;
        
        if (codecpar->codec_type == AVMEDIA_TYPE_VIDEO && *video_stream_index == -1) {
            *video_stream_index = i;
        }
        else if (codecpar->codec_type == AVMEDIA_TYPE_AUDIO && *audio_stream_index == -1) {
            *audio_stream_index = i;
        }
    }

    if (*video_stream_index == -1) {
        fprintf(stderr, "Could not find video stream\n");
        avformat_close_input(format_context);
        return -1;
    }

    AVStream *video_stream = (*format_context)->streams[*video_stream_index];
    const AVCodec *video_codec = avcodec_find_decoder(video_stream->codecpar->codec_id);
    if (!video_codec) {
        fprintf(stderr, "Unsupported video codec\n");
        avformat_close_input(format_context);
        return -1;
    }

    *video_codec_context = avcodec_alloc_context3(video_codec);
    if (!*video_codec_context) {
        fprintf(stderr, "Could not allocate video codec context\n");
        avformat_close_input(format_context);
        return -1;
    }

    if (avcodec_parameters_to_context(*video_codec_context, video_stream->codecpar) < 0) {
        fprintf(stderr, "Could not copy video codec parameters\n");
        avcodec_free_context(video_codec_context);
        avformat_close_input(format_context);
        return -1;
    }

    if (avcodec_open2(*video_codec_context, video_codec, NULL) < 0) {
        fprintf(stderr, "Could not open video codec\n");
        avcodec_free_context(video_codec_context);
        avformat_close_input(format_context);
        return -1;
    }

    if (*audio_stream_index != -1) {
        AVStream *audio_stream = (*format_context)->streams[*audio_stream_index];
        const AVCodec *audio_codec = avcodec_find_decoder(audio_stream->codecpar->codec_id);
        if (!audio_codec) {
            fprintf(stderr, "Unsupported audio codec - continuing without audio\n");
            *audio_stream_index = -1;
        } else {
            *audio_codec_context = avcodec_alloc_context3(audio_codec);
            if (!*audio_codec_context) {
                fprintf(stderr, "Could not allocate audio codec context - continuing without audio\n");
                *audio_stream_index = -1;
            } else if (avcodec_parameters_to_context(*audio_codec_context, audio_stream->codecpar) < 0) {
                fprintf(stderr, "Could not copy audio codec parameters - continuing without audio\n");
                avcodec_free_context(audio_codec_context);
                *audio_stream_index = -1;
            } else if (avcodec_open2(*audio_codec_context, audio_codec, NULL) < 0) {
                fprintf(stderr, "Could not open audio codec - continuing without audio\n");
                avcodec_free_context(audio_codec_context);
                *audio_stream_index = -1;
            }
        }
    }

    return 0;
}

void play_video(AVFormatContext *format_ctx, AVCodecContext *video_codec_ctx,
                int video_stream_idx, AVCodecContext *audio_codec_ctx,
                int audio_stream_idx)
{
    AVPacket *packet = av_packet_alloc();
    AVFrame *video_frame = av_frame_alloc();
    AVFrame *audio_frame = av_frame_alloc();
    if (!packet || !video_frame || !audio_frame) {
        fprintf(stderr, "Could not allocate frames/packet\n");
        goto cleanup;
    }

    // Initialize audio resampler if audio stream exists
    struct SwrContext *swr_ctx = NULL;
    uint8_t **resampled_data = NULL;
    int resampled_linesize = 0;
    
    if (audio_codec_ctx && audio_stream_idx != -1) {
        swr_ctx = swr_alloc();
        if (!swr_ctx) {
            fprintf(stderr, "Could not allocate resampler\n");
            goto cleanup;
        }

        AVChannelLayout out_ch_layout = {0};
        av_channel_layout_default(&out_ch_layout, audio_spec.channels);
        
        if (swr_alloc_set_opts2(&swr_ctx,
                              &out_ch_layout,
                              AV_SAMPLE_FMT_S16,
                              audio_spec.freq,
                              &audio_codec_ctx->ch_layout,
                              audio_codec_ctx->sample_fmt,
                              audio_codec_ctx->sample_rate,
                              0, NULL) < 0 || swr_init(swr_ctx) < 0) {
            fprintf(stderr, "Failed to initialize resampler\n");
            swr_free(&swr_ctx);
            audio_stream_idx = -1;
        } else {
            resampled_data = av_mallocz(sizeof(uint8_t *) * audio_spec.channels);
            if (!resampled_data) {
                fprintf(stderr, "Could not allocate samples\n");
                swr_free(&swr_ctx);
                audio_stream_idx = -1;
            }
        }
        av_channel_layout_uninit(&out_ch_layout);
    }

    // Get video time base and frame rate
    double frame_rate = av_q2d(av_guess_frame_rate(format_ctx, 
                                                 format_ctx->streams[video_stream_idx], 
                                                 NULL));
    double frame_delay = (frame_rate > 0) ? 1.0 / frame_rate : 0.04; // default to 25fps
    
    int64_t start_time = av_gettime();
    int64_t next_frame_time = start_time;

    // Main playback loop
    while (av_read_frame(format_ctx, packet) >= 0) {
        // Handle SDL events (window resize, fullscreen, etc.)
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                goto cleanup;
            }
            handle_window_event(&event);
        }

        if (packet->stream_index == video_stream_idx) {
            // Video packet processing
            if (avcodec_send_packet(video_codec_ctx, packet) < 0) {
                fprintf(stderr, "Error sending video packet\n");
                continue;
            }

            while (avcodec_receive_frame(video_codec_ctx, video_frame) == 0) {
                // Calculate current time and sleep if needed
                int64_t now = av_gettime();
                if (next_frame_time > now) {
                    av_usleep(next_frame_time - now);
                }
                
                // Render the frame (with proper scaling)
                render_frame(video_frame);
                
                // Schedule next frame
                next_frame_time += frame_delay * 1000000; // convert to microseconds
            }
        }
        else if (packet->stream_index == audio_stream_idx && audio_codec_ctx) {
            // Audio packet processing
            if (avcodec_send_packet(audio_codec_ctx, packet) < 0) {
                fprintf(stderr, "Error sending audio packet\n");
                continue;
            }

            while (avcodec_receive_frame(audio_codec_ctx, audio_frame) == 0) {
                if (swr_ctx) {
                    int out_samples = swr_get_out_samples(swr_ctx, audio_frame->nb_samples);
                    if (out_samples > 0) {
                        if (av_samples_alloc_array_and_samples(&resampled_data, &resampled_linesize,
                                                             audio_spec.channels, out_samples,
                                                             AV_SAMPLE_FMT_S16, 0) < 0) {
                            fprintf(stderr, "Could not allocate samples\n");
                            continue;
                        }

                        out_samples = swr_convert(swr_ctx, resampled_data, out_samples,
                                                (const uint8_t **)audio_frame->data, audio_frame->nb_samples);
                        if (out_samples > 0) {
                            int data_size = av_samples_get_buffer_size(NULL, audio_spec.channels,
                                                                     out_samples, AV_SAMPLE_FMT_S16, 1);
                            
                            // Don't let the audio queue get too big
                            int queued = SDL_GetQueuedAudioSize(audio_device);
                            if (queued > audio_spec.samples * audio_spec.channels * 4) {
                                SDL_ClearQueuedAudio(audio_device);
                            }
                            
                            SDL_QueueAudio(audio_device, resampled_data[0], data_size);
                        }
                        av_freep(&resampled_data[0]);
                    }
                }
            }
        }

        av_packet_unref(packet);
    }

cleanup:
    // Flush decoders
    if (video_codec_ctx) {
        avcodec_send_packet(video_codec_ctx, NULL);
    }
    if (audio_codec_ctx) {
        avcodec_send_packet(audio_codec_ctx, NULL);
    }

    // Free resources
    if (swr_ctx) swr_free(&swr_ctx);
    if (resampled_data) {
        av_freep(&resampled_data[0]);
        av_freep(&resampled_data);
    }
    av_packet_free(&packet);
    av_frame_free(&video_frame);
    av_frame_free(&audio_frame);
}

void cleanup_video(AVFormatContext *format_ctx, AVCodecContext *video_codec_ctx,
                   AVCodecContext *audio_codec_ctx)
{
    if (video_codec_ctx) avcodec_free_context(&video_codec_ctx);
    if (audio_codec_ctx) avcodec_free_context(&audio_codec_ctx);
    if (format_ctx) avformat_close_input(&format_ctx);
    avformat_network_deinit();
}
