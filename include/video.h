#ifndef VIDEO_H
#define VIDEO_H

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavutil/time.h>
#include <libswscale/swscale.h>
#include <libavutil/imgutils.h>
#include <libavutil/channel_layout.h>
#include <libswresample/swresample.h>
#include <libavutil/opt.h>
#include <unistd.h>
#include <stdio.h>

int init_video(const char *filename, AVFormatContext **format_context, 
               AVCodecContext **video_codec_context, int *video_stream_index,
               AVCodecContext **audio_codec_context, int *audio_stream_index);
void play_video(AVFormatContext *format_context, AVCodecContext *video_codec_context, 
                int video_stream_index, AVCodecContext *audio_codec_context, 
                int audio_stream_index);
void cleanup_video(AVFormatContext *format_context, AVCodecContext *video_codec_context, 
                   AVCodecContext *audio_codec_context);

#endif
