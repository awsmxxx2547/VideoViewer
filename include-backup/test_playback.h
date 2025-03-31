#ifndef DEBUG

#endif // !DEBUG

#include "test_utils.h"
#include "video.h"
#include "sdl.h"

typedef struct {
    int ret1;
    int ret2;
    int ret3;
    AVPacket *pkt;
    AVFrame *frame;
    int frames_processed;
} Playback;

Playback test_playback(const char* test_files[]);
void PlaybackTest(Playback playback);
