#include "../include/video.h"
#include "../include/sdl.h"
#include "../include/version.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc == 2 && strcmp(argv[1], "--version") == 0 || strcmp(argv[1], "-v") == 0) {
        printf("%s\n", VERSION);
        return 0;
    }

    if (argc < 2) {
        printf("Usage: %s <video_file>\n", argv[0]);
        return 1;
    }

    AVFormatContext *format_context = NULL;
    AVCodecContext *video_codec_context = NULL;
    AVCodecContext *audio_codec_context = NULL;
    int video_stream_index = -1;
    int audio_stream_index = -1;

    if (init_video(argv[1], &format_context, &video_codec_context, 
                  &video_stream_index, &audio_codec_context, &audio_stream_index) < 0) {
        printf("Video opening Error.\n");
        return 1;
    }

    if (init_sdl(video_codec_context->width, video_codec_context->height) < 0) {
        printf("SDL Initializing Error.\n");
        cleanup_video(format_context, video_codec_context, audio_codec_context);
        return 1;
    }

    if (audio_codec_context && init_audio(audio_codec_context) < 0) {
        printf("Warning: audio initialization failed - continuing without audio\n");
        avcodec_free_context(&audio_codec_context);
        audio_stream_index = -1;
    }

    play_video(format_context, video_codec_context, video_stream_index, 
              audio_codec_context, audio_stream_index);

    cleanup_video(format_context, video_codec_context, audio_codec_context);
    cleanup_sdl();

    return 0;
}
