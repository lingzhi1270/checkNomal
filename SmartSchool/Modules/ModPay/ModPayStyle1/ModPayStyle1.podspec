Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModPayStyle1"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "支付样式一"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:path => './ModPayStyle1', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = 'ModPayStyle1'
    # 子目录
    spec.subspec 'Classes' do |ss|
        ss.source_files             = 'ModPayStyle1/Classes/**/*'
    end
    
    # 资源文件
    spec.resource_bundles         = {
      'ModPayStyle1' => ['ModPayStyle1/Assets/Images/**/*']
    }
    
    # 依赖的系统库
    # spec.frameworks = "UIKit", "AnotherFramework"
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "ModPayBase"
    # 依赖的共有库
    # spec.dependency "Masonry"

    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
