#include "../../include/test_utils.h"
#include "../../include/video.h"
#include "../../include/sdl.h"
#include "../../include/test_playback.h"

int test_playback(const char *filename) {
    TEST_START("Playback Integration");
    int result = -1; // Default to failure
    
    AVFormatContext *fmt_ctx = NULL;
    AVCodecContext *video_ctx = NULL, *audio_ctx = NULL;
    AVPacket *pkt = NULL;
    AVFrame *frame = NULL;
    int video_idx = -1, audio_idx = -1;
    int frames_processed = 0;

    // Initialize video components
    int ret = init_video(filename, &fmt_ctx, &video_ctx, &video_idx, &audio_ctx, &audio_idx);
    ASSERT(ret == 0, "Video initialization");
    
    // Initialize SDL 
    ret = init_sdl(video_ctx->width, video_ctx->height);
    ASSERT(ret == 0, "SDL initialization");

    // Allocate resources
    pkt = av_packet_alloc();
    frame = av_frame_alloc();
    ASSERT(pkt != NULL, "Packet allocation");
    ASSERT(frame != NULL, "Frame allocation");

    // Test playback (5 frames max)
    while (frames_processed < 5) {
        ret = av_read_frame(fmt_ctx, pkt);
        if (ret < 0) {
            if (ret == AVERROR_EOF) {
                printf("  ℹ️ End of file reached\n");
                break;
            }
            ASSERT(0, "Frame reading");
        }

        if (pkt->stream_index == video_idx) {
            ret = avcodec_send_packet(video_ctx, pkt);
            ASSERT(ret == 0, "Packet sending");
            
            while (ret >= 0) {
                ret = avcodec_receive_frame(video_ctx, frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                    break;
                }
                ASSERT(ret == 0, "Frame receiving");
                
                render_frame(frame);
                frames_processed++;
            }
        }
        av_packet_unref(pkt);
    }

    ASSERT(frames_processed > 0, "At least one frame processed");
    printf("  ✔ Processed %d frames\n", frames_processed);
    
    result = 0; // Success

    // Cleanup resources
    if (pkt) av_packet_free(&pkt);
    if (frame) av_frame_free(&frame);
    if (fmt_ctx || video_ctx || audio_ctx) cleanup_video(fmt_ctx, video_ctx, audio_ctx);
    cleanup_sdl();

    TEST_END();
    return result;
}

void PlaybackTest(Playback playback)
{
    
}

int main() {
    int overall_result = 0;

    overall_result |= test_playback("tests/integration/test_samples/sample1.mp4");
    overall_result |= test_playback("tests/integration/test_samples/sample2.mp4");
    overall_result |= test_playback("tests/integration/test_samples/sample3.mp4");

    return overall_result;
}
