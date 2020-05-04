Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModScanBase"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "二维码扫描基类"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:git => '../ModScanBase', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = "ModScanBase"
    # 二级子目录
    spec.subspec 'Classes' do |ss|
      ss.source_files             = 'ModScanBase/Classes/**/*'
#      #  三级子目录
#      ss.subspec 'JSQSystemSoundPlayer' do |sss|
#        sss.source_files          = 'ModScanBase/Classes/JSQSystemSoundPlayer/*.{h,m}'
#      end
    end
    
    # 资源文件
    # spec.resources = "ModScanBase/Resources/**/*.png"
    
    # 依赖的私系统库
    # spec.frameworks = "someFramework", "AnotherFramework"
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    # 依赖的共有库
    # spec.dependency ""
    
    
    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    spec.static_framework = true
end
