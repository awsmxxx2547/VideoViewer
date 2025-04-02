#ifndef SDL_H
#define SDL_H

#include <SDL2/SDL.h>
#include <libavutil/frame.h>
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <stdio.h>

#define TITLE "Video Viewer"

extern SDL_Window *window;
extern SDL_Renderer *renderer;
extern SDL_Texture *texture;
extern SDL_AudioSpec audio_spec;
extern SDL_AudioDeviceID audio_device;
extern int original_width;
extern int original_height;
extern int is_fullscreen;

#define CHECK_IF(cond, msg) \
    if (cond) { \
        fprintf_s(stderr, "%s: %s\n", msg, SDL_GetError()); \
        return -1; \
    }

int init_sdl(int width, int height);
int init_audio(AVCodecContext *audio_codec_context);
void render_frame(AVFrame *frame);
void toggle_fullscreen();
void handle_window_event(SDL_Event *event);
void cleanup_sdl();

#endif
