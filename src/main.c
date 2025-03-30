#include "../include/version.h"
#include "../include/video.h"
#include "../include/sdl.h"

void install_dependencies() {
    printf("Installing required dependencies...\n");
    #ifdef __linux__
        system("sudo apt-get update && sudo apt-get install -y curl unzip libsdl2-dev libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libswresample-dev");
    #elif __APPLE__
        system("brew update && brew install curl unzip sdl2 ffmpeg");
    #elif _WIN32
        system("choco install -y curl unzip mingw ffmpeg sdl2");
    #endif
}

void check_for_updates() {
    printf("Checking for updates...\n");
    install_dependencies();
    system("curl -s https://api.github.com/repos/awsmxxx2547/VideoViewer/releases/latest | grep tag_name");
}

int main(int argc, char *argv[])
{
    // Show version
    if (argc == 2 && strcmp(argv[1], "--version") == 0) {
        print_version_info();
        return 0;
    }

    // Update
    if (argc > 1 && strcmp(argv[1], "--update") == 0) {
        check_for_updates();
        return 0;
    }

    printf("Video Viewer %s\n", VERSION);

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
