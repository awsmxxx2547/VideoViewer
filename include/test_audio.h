#ifndef TEST_AUDIO_H
#define TEST_AUDIO_H

#include "test_utils.h"
#include "sdl.h"
#include "video.h"

typedef struct {
    int init;
    int audio_device;
} AudioInit;

typedef struct {
    int swr_init;
    int out_samples;
    
} AudioResample;

AudioInit test_audio_initialization();
AudioResample test_audio_resampling();
void AudioInitTest(AudioInit audio);
void AudioResampleTest(AudioResample audio);

#endif
