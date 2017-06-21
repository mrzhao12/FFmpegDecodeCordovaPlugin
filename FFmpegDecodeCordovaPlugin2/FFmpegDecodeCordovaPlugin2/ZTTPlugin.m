/**
 *FFmpegDecodeCordovaPlugin
 *赵彤彤 mrzhao12  ttdiOS
 *1107214478@qq.com
 *http://www.jianshu.com/u/fd9db3b2363b
 *本程序是iOS平台下cordova简单自定义插件FFmpeg解码flv,mp4文件为yuv像素文件
 *1.cordova简单自定义插件flv格式解码yuv
 */

//  ZTTPlugin.m
//  FFmpegDecodeCordovaPlugin2
//
//  Created by sjhz on 2017/6/21.
//  Copyright © 2017年 sjhz. All rights reserved.
//

#import "ZTTPlugin.h"

@implementation ZTTPlugin
- (void)myMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* myarg = [command.arguments objectAtIndex:0];
    if (myarg != nil) {
        //        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self FFMpegDecode];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arg was null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}




- (void)FFMpegDecode{
    // 文件
    AVFormatContext	*pFormatCtx;
    int				i, videoindex;
    // 编码器
    AVCodecContext	*pCodecCtx;
    AVCodec			*pCodec;
    AVFrame	*pFrame,*pFrameYUV;
    uint8_t *out_buffer;
    AVPacket *packet;
    int y_size;
    int ret, got_picture;
    struct SwsContext *img_convert_ctx;
    FILE *fp_yuv;
    int frame_cnt;
    clock_t time_start, time_finish;
    double  time_duration = 0.0;
    
    char input_str_full[500]={0};
    char output_str_full[500]={0};
    char info[1000]={0};
    
    //    NSString *input_str= [NSString stringWithFormat:@"resource.bundle/%@",self.inputurl.text];
    const char *input_str = [[[NSBundle mainBundle] pathForResource:@"521_720x576" ofType:@"flv"]  cStringUsingEncoding:NSUTF8StringEncoding];
    
    const char* out_file = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"decoder_521_720x576.yuv"] cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    //    NSString *output_str= [NSString stringWithFormat:@"resource.bundle/%@",self.outputurl.text];
    
    //    NSString *input_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:input_str];
    //    NSString *output_nsstr=[[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:output_str];
    //
    //    sprintf(input_str_full,"%s",[input_nsstr UTF8String]);
    
    sprintf(input_str_full,"%s",input_str);
    sprintf(output_str_full,"%s",out_file);
    
    printf("Input Path:%s\n",input_str_full);
    printf("Output Path:%s\n",output_str_full);
    //1. 注册所有编码器 注册所支持的所有文件（容器）格式以及对应的codec
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    //2.打开视频文件 打开文件 int avformat_open_input(AVFormatContext **ps, const char *filename, AVInputFormat *fmt, AVDictionary **options);
    if(avformat_open_input(&pFormatCtx,input_str_full,NULL,NULL)!=0){
        printf("Couldn't open input stream.\n");
        return ;
    }
    
    
    //3. 检查数据流 从文件中提取流信息
    if(avformat_find_stream_info(pFormatCtx,NULL)<0){
        printf("Couldn't find stream information.\n");
        return;
    }
    
    videoindex=-1;
    for(i=0; i<pFormatCtx->nb_streams; i++)
    //4.在多个数据流中找到视频流 类型为：AVMEDIA_TYPE_VIDEO
    if(pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO){
        videoindex=i;
        break;
    }
    if(videoindex==-1){
        printf("Couldn't find a video stream.\n");
        return;
    }
    pCodecCtx=pFormatCtx->streams[videoindex]->codec;
    //5.查找解码器 查找video stream 相对应的解码器。 找到解码文件的解码器编号
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec==NULL){
        printf("Couldn't find Codec没有找到解码器.\n");
        return;
    }
    //6.打开解码器
    if(avcodec_open2(pCodecCtx, pCodec,NULL)<0){
        printf("Couldn't open codec打开解码器失败.\n");
        return;
    }
    //7.找一个地方保存帧 ，分配视频帧 为解码帧分配内存。     AVFrame	*pFrame,*pFrameYUV;
    pFrame=av_frame_alloc();
    pFrameYUV=av_frame_alloc();
    // 8.uint8_t *out_buffer; 指向数据地址的指针 一帧大小的缓冲区
    out_buffer=(uint8_t *)av_malloc(avpicture_get_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height));
    // int avpicture_fill(AVPicture *picture, const uint8_t *ptr,
    //    enum AVPixelFormat pix_fmt, int width, int height);    将pFrame的大小设为out_buffer。 用avpicture_fill来把帧和我们新申请的内存来结合。关于AVPicture的结成：AVPicture结构体是AVFrame结构体的子集――AVFrame结构体的开始部分与AVPicture结构体是一样的。
    avpicture_fill((AVPicture *)pFrameYUV, out_buffer, AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    // 9.存储解码前数据的结构体 初始化packet
    packet=(AVPacket *)av_malloc(sizeof(AVPacket));
    /*
     struct SwsContext *sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat,
     int dstW, int dstH, enum AVPixelFormat dstFormat,
     int flags, SwsFilter *srcFilter,
     SwsFilter *dstFilter, const double *param);
     */
    // 获取转码的参数
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                     pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);
    
    
    sprintf(info,   "[Input     ]%s\n", input_str);
    sprintf(info, "%s[Output    ]%s\n",info,out_file);
    sprintf(info, "%s[Format    ]%s\n",info, pFormatCtx->iformat->name);
    sprintf(info, "%s[Codec     ]%s\n",info, pCodecCtx->codec->name);
    sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
    // NSLog(@"******info:%s",info);
    printf("$$$$$$$$%s",info);
    fp_yuv=fopen(output_str_full,"wb+");
    if(fp_yuv==NULL){
        printf("Cannot open output file.\n");
        return;
    }
    
    frame_cnt=0;
    time_start = clock();
    // 我们将要做的是通过读取包来读取整个视频流，然后把它解码成帧，最好后转换格式并且保存。
    // 从流中读取数据到packet中 av_read_frame   读取一帧数据
    // av_read_frame()读取一个包并且把它保存到AVPacket结构体中 ／／ 不停的从码流里提取帧数据
    while(av_read_frame(pFormatCtx, packet)>=0){
        if(packet->stream_index==videoindex){
            // // 如果包中的流是视频数据，就将它转码.其中的got_picture可以认为是一个标志，如果解码成功则不为NULL，
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if(ret < 0){
                printf("Decode Error.\n");
                return;
            }
            if(got_picture){
                // 转码的数据
                sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height,
                          pFrameYUV->data, pFrameYUV->linesize);
                // 现在的pFrameYUv里面就是我们需要的yuv数据。
                // NSLog(@"-----pFrameYUV:%d",pFrameYUV->data);
                y_size=pCodecCtx->width*pCodecCtx->height;
                fwrite(pFrameYUV->data[0],1,y_size,fp_yuv);    //Y
                fwrite(pFrameYUV->data[1],1,y_size/4,fp_yuv);  //U
                fwrite(pFrameYUV->data[2],1,y_size/4,fp_yuv);  //V
                //Output info
                char pictype_str[10]={0};
                switch(pFrame->pict_type){
                    case AV_PICTURE_TYPE_I:sprintf(pictype_str,"I");break;
                    case AV_PICTURE_TYPE_P:sprintf(pictype_str,"P");break;
                    case AV_PICTURE_TYPE_B:sprintf(pictype_str,"B");break;
                    default:sprintf(pictype_str,"Other");break;
                }
                printf("Frame Index: %5d. Type:%s\n",frame_cnt,pictype_str);
                frame_cnt++;
            }
        }
        // 释放YUV frame
        av_free_packet(packet);
    }
    //flush decoder
    //FIX: Flush Frames remained in Codec
    while (1) {
        ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
        if (ret < 0)
        break;
        if (!got_picture)
        break;
        //  img_convert()函数来把帧从原始格式（pCodecCtx->pix_fmt）转换成为YUV格式
        sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height,
                  pFrameYUV->data, pFrameYUV->linesize);
        int y_size=pCodecCtx->width*pCodecCtx->height;
        fwrite(pFrameYUV->data[0],1,y_size,fp_yuv);    //Y
        fwrite(pFrameYUV->data[1],1,y_size/4,fp_yuv);  //U
        fwrite(pFrameYUV->data[2],1,y_size/4,fp_yuv);  //V
        //Output info
        char pictype_str[10]={0};
        switch(pFrame->pict_type){
            case AV_PICTURE_TYPE_I:sprintf(pictype_str,"I");break;
            case AV_PICTURE_TYPE_P:sprintf(pictype_str,"P");break;
            case AV_PICTURE_TYPE_B:sprintf(pictype_str,"B");break;
            default:sprintf(pictype_str,"Other");break;
        }
        printf("Frame Index: %5d. Type:%s\n",frame_cnt,pictype_str);
        frame_cnt++;
    }
    time_finish = clock();
    time_duration=(double)(time_finish - time_start);
    
    sprintf(info, "%s[Time      ]%fus\n",info,time_duration);
    sprintf(info, "%s[Count     ]%d\n",info,frame_cnt);
    
    sws_freeContext(img_convert_ctx);
    
    fclose(fp_yuv);
    //释放内存
    av_frame_free(&pFrameYUV);
    av_frame_free(&pFrame);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
    
    //    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    //    self.infomation.text=info_ns;
    
    
    
    
    
    
}

@end
