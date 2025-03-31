#include "../../include/test_audio.h"
#include "../../include/test_decoder.h"

int main()
{
    const char* test_files[] = {
        "tests/integration/test_samples/sample1.mp4",
        "tests/integration/test_samples/sample2.mp4",
        "tests/integration/test_samples/sample3.mp4",
        NULL
    };

    DecoderHeader DECODER_HEADER = DecoderInit(test_files);
    DecoderTest(DECODER_HEADER);

    AudioInit AUDIO_INIT = test_audio_initialization();
    AudioResample AUDIO_RESAMPLE = test_audio_resampling();

    AudioInitTest(AUDIO_INIT);
    AudioResampleTest(AUDIO_RESAMPLE);

    // Cleanup in reverse order of initialization
    if (AUDIO_INIT.audio_device) {
        SDL_ClearQueuedAudio(AUDIO_INIT.audio_device);
        SDL_CloseAudioDevice(AUDIO_INIT.audio_device);
    }
    SDL_Quit();

    return 0;
}
