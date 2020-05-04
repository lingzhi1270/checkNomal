Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModScanStyle1"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "二维码扫描样式一"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:git => '../ModScanStyle1', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = "ModScanStyle1"
    # 二级子目录
    spec.subspec 'Classes' do |ss|
      ss.source_files             = "ModScanStyle1/Classes/**/*"
    end
    
    # 资源文件
    spec.resource_bundles         = {
      'ModScanStyle1' => ['ModScanStyle1/Assets/*']
    }
    
    # 依赖的私系统库
    spec.frameworks = "UIKit", "AVFoundation"
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "ModScanBase"
    # 依赖的共有库
    spec.dependency "TZImagePickerController" # 图片浏览器
    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
