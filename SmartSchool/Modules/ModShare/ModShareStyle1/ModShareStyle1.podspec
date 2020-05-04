Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModShareStyle1"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "分享样式一"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:path => './ModShareStyle1', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = 'ModShareStyle1'
    # 二级子目录
    spec.subspec 'Classes' do |ss|
        ss.source_files             = 'ModShareStyle1/Classes/'
        
        ss.subspec 'Views' do |sss|
            sss.source_files             = 'ModShareStyle1/Classes/Views/*.{h,m}'
        end
    end

    # 资源文件
    spec.resource_bundles         = {
      'ModShareStyle1' => ['ModShareStyle1/Assets/Images/**/*']
    }

    # 依赖的系统库
    # spec.frameworks = "UIKit", "AnotherFramework"

    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "LibDataModel"
    spec.dependency "ModShareBase"
    # 依赖的共有库
    spec.dependency 'mob_sharesdk'                              # 主模块(必须)
    spec.dependency 'mob_sharesdk/ShareSDKPlatforms/QQ'         # 平台SDK模块(QQ)
    spec.dependency 'mob_sharesdk/ShareSDKPlatforms/WeChatFull'

    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
