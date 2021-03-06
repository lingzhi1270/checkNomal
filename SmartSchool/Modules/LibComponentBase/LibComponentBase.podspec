Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "LibComponentBase"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "基础配置类"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:git => '../LibComponentBase', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = "LibComponentBase"
    # 二级子目录
    spec.subspec 'Classes' do |ss|
      ss.source_files             = 'LibComponentBase/Classes/**/*'
    end
    # 资源文件
    spec.resource_bundles         = {
      'LibComponentBase' => ['LibComponentBase/Assets/Images/**/*', 'LibComponentBase/Assets/Videos/**/*']
    }
    # 依赖的系统库
    spec.frameworks = "UIKit", "AVFoundation"
    
    # 依赖的私有库
    # spec.dependency ""
    
    # 依赖的共有库
    spec.dependency "AFNetworking"          # AFNetworking
    spec.dependency "MJRefresh"             # MJRefresh
    spec.dependency "YYKit"                 # YYKit
    spec.dependency "ViroyalTools"          # 工具类
    spec.dependency "Masonry"
    spec.dependency "SDWebImage"
    spec.dependency "GPUImage"
    spec.dependency 'MBProgressHUD', '~> 1.1.0'
    spec.dependency "IQKeyboardManager"
    
    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
