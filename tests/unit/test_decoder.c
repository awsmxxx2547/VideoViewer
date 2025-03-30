#include "test_decoder.h"
#include <stdio.h>

DecoderHeader DecoderInit(const char* test_files[])
{
    if (!test_files || !test_files[0]) {
        fprintf(stderr, "DecoderInit: test_files is NULL or empty.\n");
        exit(1);
    }

    DecoderHeader decoder;
    decoder.count = 0;

    // Count valid files
    while (test_files[decoder.count]) {
        if (test_files[decoder.count] == NULL) break;  // Extra safety check
        printf("DecoderInit: Processing file %d: %s\n", decoder.count, test_files[decoder.count]);
        decoder.count++;
    }

    // Allocate memory
    decoder.data = (Decoder*)malloc(decoder.count * sizeof(Decoder));
    if (!decoder.data) {
        fprintf(stderr, "DecoderInit: Memory allocation failed\n");
        exit(1);
    }

    // Initialize each file
    for (int i = 0; i < decoder.count; i++) {
        decoder.data[i].fmt_ctx          = NULL;
        decoder.data[i].video_codec_ctx  = NULL;
        decoder.data[i].audio_codec_ctx  = NULL;
        decoder.data[i].video_stream_idx = -1;
        decoder.data[i].audio_stream_idx = -1;
        decoder.data[i].ret              = 0;

        decoder.data[i].ret = init_video(test_files[i], &decoder.data[i].fmt_ctx,
                                         &decoder.data[i].video_codec_ctx, &decoder.data[i].video_stream_idx,
                                         &decoder.data[i].audio_codec_ctx, &decoder.data[i].audio_stream_idx);

        if (decoder.data[i].ret < 0) {
            fprintf(stderr, "DecoderInit: Failed to initialize video for file %s\n", test_files[i]);
            exit(1);
        }
    }

    return decoder;
}
void DecoderTest(DecoderHeader decoder)
{
    int SUCCESS_ret_count               = 0;
    int SUCCESS_fmt_ctx_count           = 0;
    int SUCCESS_video_codec_ctx_count   = 0;
    int SUCCESS_audio_codec_ctx_count   = 0;
    int SUCCESS_video_stream_idx_count  = 0;
    int SUCCESS_audio_stream_idx_count  = 0;

    TEST_START("Video Decoder");
    for(int i = 0; i < decoder.count; i++)
    {
        if(decoder.data[i].ret == 0)
            SUCCESS_ret_count++;
        if(decoder.data[i].fmt_ctx != NULL)
            SUCCESS_fmt_ctx_count++;
        if(decoder.data[i].video_codec_ctx != NULL)
            SUCCESS_video_codec_ctx_count++;
        if(decoder.data[i].audio_codec_ctx != NULL)
            SUCCESS_audio_codec_ctx_count++;
        if(decoder.data[i].video_stream_idx >= 0)
            SUCCESS_video_stream_idx_count++;
        if(decoder.data[i].audio_stream_idx >= 0)
            SUCCESS_audio_stream_idx_count++;
    };
    
    ASSERT_S(SUCCESS_ret_count                == decoder.count, "Decoder initialization", SUCCESS_ret_count,              decoder.count);
    ASSERT_S(SUCCESS_fmt_ctx_count            == decoder.count, "Format context",         SUCCESS_fmt_ctx_count,          decoder.count);
    ASSERT_S(SUCCESS_video_codec_ctx_count    == decoder.count, "Video codec context",    SUCCESS_video_codec_ctx_count,  decoder.count);
    ASSERT_S(SUCCESS_audio_codec_ctx_count    == decoder.count, "Audio codec context",    SUCCESS_audio_codec_ctx_count,  decoder.count);
    ASSERT_S(SUCCESS_video_stream_idx_count   == decoder.count, "Video stream index",     SUCCESS_video_stream_idx_count, decoder.count);
    ASSERT_S(SUCCESS_audio_stream_idx_count   == decoder.count, "Audio stream index",     SUCCESS_audio_stream_idx_count, decoder.count);
    printf("Test Count: %d\n", decoder.count);

    // Cleanup each decoder before freeing the array
    for (int i = 0; i < decoder.count; i++) {
        cleanup_video(decoder.data[i].fmt_ctx, decoder.data[i].video_codec_ctx, decoder.data[i].audio_codec_ctx);
    }
    free(decoder.data);
    
    TEST_END();
}
