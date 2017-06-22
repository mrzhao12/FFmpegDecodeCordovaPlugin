# FFmpegDecodeCordovaPlugin
FFmpegDecodeCordovaPlugin
/**
 *FFmpegDecodeCordovaPlugin
 *赵彤彤 mrzhao12  ttdiOS
 *1107214478@qq.com

 http://www.jianshu.com/p/d9f08aaaa0d2
 
 *本程序是iOS平台下cordova简单自定义插件FFmpeg解码flv,mp4文件为yuv像素文件
 *1.cordova简单自定义插件flv格式解码yuv
 */
 
Cordova进行iOS开发 (已存FFmpeg项目中添加Cordova及自定义插件)

主要介绍的是iOS端项目实战，以及简单的将Cordova集成到自己的工程项目中(iOS的FFmpeg项目)的方法，以及添加Cordova自定义插件的简单使用。本文的自定义插件是纯代码的实现，至于在终端创建自定义cordova插件请查看官网介绍：http://cordova.axuer.com/plugins/

其实最终实现的效果就是在js网页界面点击网页里的按钮触发ffmpeg解码的效果，即自定义cordova插件，你也可以自定义其他的插件（如访问相机相册，像原生app一样去访问手机里的内容）从而实现小混合开发（webapp）

关于业务的web页面需要调用原生的相机，相册，地理位置，扫描二维码等一系列功能，这就涉及到js与原生交互的问题了。起初iOS端提出的方案是直接用WebView或者用WKWebView嵌套就好了，因为应要求，只要web端发送一个假的请求，然后手机端断掉截住这个请求也是可以实现交互的，不过安卓因为其平台多样性和特殊性这个就不兼容而且可行性交差，这是安卓给的说法，可是不管怎么说，反正最后确定双方都用Cordova实现该功能

至于iOS端cordova的配置请查看的上一篇文章，绝对是笔者亲身经历，有图有真相（第一次经历确实有点坑），iOS版Cordova安装开发

