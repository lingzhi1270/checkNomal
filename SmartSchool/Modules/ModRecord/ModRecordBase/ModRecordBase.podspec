Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModRecordBase"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "录音基类"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:git => '../ModRecordBase', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    
    # 源码文件
    spec.source_files           = "ModRecordBase"
    spec.subspec 'Classes' do |ss|
      ss.source_files = 'ModRecordBase/Classes/**/*.{h,m}'
    end
    
    # 资源文件
#    spec.resources = "ModRecordBase/Resources/**/*.png"
    
    # 系统库
    # spec.frameworks = "UIKit", "AnotherFramework"
    
    # 第三方依赖
    # spec.dependency "mob_sharesdk"
    # spec.dependency "mob_sharesdk/ShareSDKPlatforms/QQ"
    # spec.dependency "mob_sharesdk/ShareSDKPlatforms/WeChat"

    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"

end
