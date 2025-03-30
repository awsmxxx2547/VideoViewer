#ifndef TEST_DECODER_H
#define TEST_DECODER_H

#include "test_utils.h"
#include "video.h"

typedef struct {
    int ret;
    AVFormatContext *fmt_ctx;
    AVCodecContext  *video_codec_ctx;
    AVCodecContext  *audio_codec_ctx;
    int             video_stream_idx;
    int             audio_stream_idx;
} Decoder;

typedef struct {
    Decoder*    data;
    int         count;
} DecoderHeader;

DecoderHeader DecoderInit(const char* test_files[]);
void DecoderTest(DecoderHeader decoder);

#endif // !TEST_DECODER_H
