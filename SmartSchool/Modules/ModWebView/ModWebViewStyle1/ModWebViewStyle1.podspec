Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModWebViewStyle1"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "ModWebViewStyle1样式一"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:git => '../ModWebViewStyle1', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = "ModWebViewStyle1"
    # 二级子目录
    spec.subspec 'Classes' do |ss|
      ss.source_files             = "ModWebViewStyle1/Classes/**/*"
    end
    
    # 资源文件
    # spec.resource_bundles         = ''
    
    # 系统库
    spec.frameworks = "AVKit", "WebKit", "Photos"
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "LibDataModel"
    ## 上传
    spec.dependency "LibUpload"
    ## 模块控制器
    spec.dependency "ModApps"
    ## 登录
    spec.dependency "ModLoginBase"
    ## 摄像头
    spec.dependency "ModCameraBase"
    ## 联系人
    spec.dependency "ModContactBase"
    ## 定位
    spec.dependency "ModLocationBase"
    ## 菜单
    spec.dependency "ModMenuBase"
    ## 导航
    spec.dependency "ModNavigationBase"
    ## 支付
    spec.dependency "ModPayBase"
    ## 分享
    spec.dependency "ModShareBase"
    ## 二维码
    spec.dependency "ModScanBase"
    ## 音视频播放
    spec.dependency "ModPlayerBase"
    ## 录音
    spec.dependency "ModRecordBase"
    ## 文字转语音
    spec.dependency "ModTTSBase"
    # 依赖的共有库
    spec.dependency "AFNetworking"
    spec.dependency "WebViewJavascriptBridge"   
    
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
