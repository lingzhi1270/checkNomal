Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModAdvertisementBase"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "模块管理类"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:path => './ModAdvertisementBase', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = 'ModAdvertisementBase'
    # 子目录
    spec.subspec 'Classes' do |ss|
        ss.source_files             = 'ModAdvertisementBase/Classes/**/*'
    end
    
    # 资源文件
    # spec.resource_bundles         = {
    #   'ModAdvertisementBase' => ['ModAdvertisementBase/Classes/*.xcdatamodeld']
    # }
    
    # 依赖的系统库
    # spec.frameworks = "UIKit", "AnotherFramework"
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "LibCoredata"
    spec.dependency "LibDataModel"
    # 依赖的共有库
    spec.dependency "WebViewJavascriptBridge"

    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
