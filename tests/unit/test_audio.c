#include "../../include/test_audio.h"

AudioInit test_audio_initialization()
{
    AudioInit audioInit;
    if (SDL_Init(SDL_INIT_AUDIO) < 0) {
        fprintf(stderr, "SDL could not initialize! SDL_Error: %s\n", SDL_GetError());
        exit(1);
    }

    AVCodecContext *audio_ctx = avcodec_alloc_context3(NULL);
    if (!audio_ctx) {
        fprintf(stderr, "Failed to allocate AVCodecContext\n");
        exit(1);
    }
    audio_ctx->sample_rate = 44100;
    audio_ctx->ch_layout.nb_channels = 2;
    audio_ctx->sample_fmt = AV_SAMPLE_FMT_FLTP;

    audioInit.init = init_audio(audio_ctx);
    audioInit.audio_device = audio_device;

    avcodec_free_context(&audio_ctx);

    return audioInit;
}

AudioResample test_audio_resampling()
{
    AudioResample audioResample = {0};

    // Setup test audio frame
    AVFrame *frame = av_frame_alloc();
    if (!frame) {
        fprintf(stderr, "Failed to allocate frame\n");
        exit(1);
    }

    frame->sample_rate = 48000;
    av_channel_layout_default(&frame->ch_layout, 6); // 5.1 channel
    frame->format = AV_SAMPLE_FMT_FLTP;
    frame->nb_samples = 1024;
    
    // Allocate buffer for the frame
    if (av_frame_get_buffer(frame, 0) < 0) {
        fprintf(stderr, "Failed to allocate frame data\n");
        av_frame_free(&frame);
        exit(1);
    }

    // Test resampling to stereo
    struct SwrContext *swr = swr_alloc();
    if (!swr) {
        fprintf(stderr, "Failed to allocate resampler\n");
        av_frame_free(&frame);
        exit(1);
    }

    AVChannelLayout out_layout = {0};
    av_channel_layout_default(&out_layout, 2);

    int ret = swr_alloc_set_opts2(&swr,
                       &out_layout, AV_SAMPLE_FMT_S16, 44100,
                       &frame->ch_layout, frame->format, frame->sample_rate,
                       0, NULL);
    if (ret < 0) {
        fprintf(stderr, "Failed to set resampler options\n");
        swr_free(&swr);
        av_frame_free(&frame);
        exit(1);
    }

    audioResample.swr_init = swr_init(swr);
    if (audioResample.swr_init < 0) {
        fprintf(stderr, "Failed to initialize resampler\n");
        swr_free(&swr);
        av_frame_free(&frame);
        exit(1);
    }

    uint8_t **resampled_data = NULL;
    int linesize;
    ret = av_samples_alloc_array_and_samples(&resampled_data, &linesize, 2,
                                     frame->nb_samples, AV_SAMPLE_FMT_S16, 0);
    if (ret < 0) {
        fprintf(stderr, "Failed to allocate resampled data\n");
        swr_free(&swr);
        av_frame_free(&frame);
        exit(1);
    }

    audioResample.out_samples = swr_convert(swr, resampled_data, frame->nb_samples,
                                (const uint8_t **)frame->data, frame->nb_samples);

    // Cleanup
    swr_free(&swr);
    if (resampled_data) {
        av_freep(&resampled_data[0]);
        av_freep(&resampled_data);
    }
    av_frame_free(&frame);

    return audioResample;
}

void AudioInitTest(AudioInit audio)
{
    TEST_START("Audio Initialization");
    ASSERT(audio.init == 0, "Audio initialization");
    ASSERT(audio.audio_device != 0, "Audio device creation");
    TEST_END();
}

void AudioResampleTest(AudioResample audio)
{
    TEST_START("Audio Resampling");
    ASSERT(audio.swr_init >= 0, "Resampler initialization");
    ASSERT(audio.out_samples > 0, "Successful resampling");
    TEST_END();
}
