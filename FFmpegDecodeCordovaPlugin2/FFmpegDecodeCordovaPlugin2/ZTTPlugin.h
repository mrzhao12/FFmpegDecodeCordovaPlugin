/**
 *FFmpegDecodeCordovaPlugin
 *赵彤彤 mrzhao12  ttdiOS
 *1107214478@qq.com
 *http://www.jianshu.com/u/fd9db3b2363b
 *本程序是iOS平台下cordova简单自定义插件FFmpeg解码flv,mp4文件为yuv像素文件
 *1.cordova简单自定义插件flv格式解码yuv
 */

//  ZTTPlugin.h
//  FFmpegDecodeCordovaPlugin2
//
//  Created by sjhz on 2017/6/21.
//  Copyright © 2017年 sjhz. All rights reserved.
//

//#import <Cordova/Cordova.h>
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#import <Cordova/CDVPlugin.h>
@interface ZTTPlugin : CDVPlugin

- (void)myMethod:(CDVInvokedUrlCommand*)command;
@end
