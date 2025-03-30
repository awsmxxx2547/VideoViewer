#include "../include/sdl.h"
#include <SDL2/SDL.h>

SDL_Window *window = NULL;
SDL_Renderer *renderer = NULL;
SDL_Texture *texture = NULL;
SDL_AudioSpec audio_spec;
SDL_AudioDeviceID audio_device = 0;
int video_width = 0;
int video_height = 0;
int is_fullscreen = 0;



int init_sdl(int width, int height) 
{
    video_width = width;
    video_height = height;

    CHECK_IF(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0, "SDL Error");

    window = SDL_CreateWindow(TITLE,
                            SDL_WINDOWPOS_CENTERED,
                            SDL_WINDOWPOS_CENTERED,
                            width, height,
                            SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    CHECK_IF(!window, "Window Error");

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    CHECK_IF(!renderer, "Renderer Error");

    texture = SDL_CreateTexture(renderer,
                              SDL_PIXELFORMAT_YV12,
                              SDL_TEXTUREACCESS_STREAMING,
                              width, height);
    CHECK_IF(!texture, "Texture Error");

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
    return 0;
}

void toggle_fullscreen() 
{
    is_fullscreen = !is_fullscreen;
    SDL_SetWindowFullscreen(window, is_fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
    
    if (!is_fullscreen) {
        SDL_SetWindowSize(window, video_width, video_height);
        SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
    }
}

void handle_window_event(SDL_Event *event) 
{
    if (event->type == SDL_KEYDOWN) {
        switch (event->key.keysym.sym) {
            case SDLK_f:
                toggle_fullscreen();
                break;
            case SDLK_ESCAPE:
                if (is_fullscreen) {
                    toggle_fullscreen();
                }
                break;
        }
    }
}

void render_frame(AVFrame *frame) 
{
    // Update texture with new frame data
    SDL_UpdateYUVTexture(texture, NULL,
                        frame->data[0], frame->linesize[0],
                        frame->data[1], frame->linesize[1],
                        frame->data[2], frame->linesize[2]);

    // Clear screen
    SDL_RenderClear(renderer);
    
    // Get current window size
    int window_width, window_height;
    SDL_GetWindowSize(window, &window_width, &window_height);
    
    // Calculate aspect ratio
    float video_aspect = (float)video_width / video_height;
    float window_aspect = (float)window_width / window_height;
    
    SDL_Rect dst_rect;
    
    if (window_aspect > video_aspect) {
        // Window is wider than video (letterbox)
        int height = window_height;
        int width = (int)(height * video_aspect);
        dst_rect.x = (window_width - width) / 2;
        dst_rect.y = 0;
        dst_rect.w = width;
        dst_rect.h = height;
    } else {
        // Window is taller than video (pillarbox)
        int width = window_width;
        int height = (int)(width / video_aspect);
        dst_rect.x = 0;
        dst_rect.y = (window_height - height) / 2;
        dst_rect.w = width;
        dst_rect.h = height;
    }
    
    // Render the texture
    SDL_RenderCopy(renderer, texture, NULL, &dst_rect);
    SDL_RenderPresent(renderer);
}

int init_audio(AVCodecContext *audio_codec_ctx)
{
    if (!SDL_WasInit(SDL_INIT_AUDIO)) {
        printf("Audio subsystem not initialized\n");
        return -1;
    }

    SDL_AudioSpec wanted_spec, obtained_spec;
    SDL_zero(wanted_spec);
    
    wanted_spec.freq = audio_codec_ctx->sample_rate;
    wanted_spec.format = AUDIO_S16SYS;
    wanted_spec.channels = audio_codec_ctx->ch_layout.nb_channels;
    wanted_spec.silence = 0;
    wanted_spec.samples = FFMAX(1024, audio_codec_ctx->frame_size);
    wanted_spec.callback = NULL;

    audio_device = SDL_OpenAudioDevice(NULL, 0, &wanted_spec, &obtained_spec,
                                     SDL_AUDIO_ALLOW_FREQUENCY_CHANGE | 
                                     SDL_AUDIO_ALLOW_CHANNELS_CHANGE |
                                     SDL_AUDIO_ALLOW_SAMPLES_CHANGE);

    CHECK_IF(audio_device == 0, "Failed to open audio device");

    if (obtained_spec.format != wanted_spec.format) {
        printf("Warning: Got audio format %d instead of %d\n", obtained_spec.format, wanted_spec.format);
    }

    audio_spec = obtained_spec;
    SDL_PauseAudioDevice(audio_device, 0);
    return 0;
}

void cleanup_sdl() 
{
    if (audio_device != 0) {
        SDL_ClearQueuedAudio(audio_device);
        SDL_CloseAudioDevice(audio_device);
    }
    if (texture) SDL_DestroyTexture(texture);
    if (renderer) SDL_DestroyRenderer(renderer);
    if (window) SDL_DestroyWindow(window);
    SDL_Quit();
}
