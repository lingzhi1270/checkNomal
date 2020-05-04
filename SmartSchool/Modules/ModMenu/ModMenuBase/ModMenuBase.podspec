Pod::Spec.new do |spec|
    # 库名
    spec.name                     = "ModMenuBase"
    # 库版本
    spec.version                  = "1.0.0"
    # 库简介
    spec.summary                  = "菜单基类"
    # 库链接
    spec.homepage                 = "http://www.example.com"
    # 协议
    spec.license                  = 'MIT'
    # 作者
    spec.author                   = { "tangqi" => "tangqi@viroyal.cn" }
    # 来源
    spec.source                   = {:path => './ModMenuBase', :tag => spec.version.to_s }
    # 最低编译版本
    spec.ios.deployment_target    = '10.0'
    # 源码文件
    spec.source_files             = 'ModMenuBase'
    # 二级子目录
    spec.subspec 'Classes' do |ss|
      ss.source_files             = 'ModMenuBase/Classes/**/*'
      
    end
  
    # 依赖的私有库
    spec.dependency "LibComponentBase"
    spec.dependency "ModMenuStyle1"

    # spec.library   = "iconv"
    # spec.libraries = "iconv", "xml2"
    
    spec.static_framework = true
end
