project 'SmartSchool.xcodeproj'

platform :ios, '10.0'
inhibit_all_warnings!
#use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/aliyun/aliyun-specs.git'

def pods
    # 私有库
    pod 'ViroyalTools',             :git => 'https://github.com/NJDevTangQi/ViroyalTools.git'
    pod 'ViroyalCoreDataSource',    :git => 'https://github.com/NJDevTangQi/ViroyalCoreDataSource.git'
    pod 'GFPopover',                :git => 'https://code.aliyun.com/guofengtd/GFPopover.git'

    #************************************************************************************#
    #*******************************     本地Pod库     **********************************#
    #************************************************************************************#
    
    #*********************************   基础配置库   *************************************#
    #************************************ 不可编辑 ****************************************#
    ## 基本配置
    pod 'LibComponentBase',     :path => './SmartSchool/Modules/LibComponentBase'
    ## 主题管理类
    pod 'LibTheme',             :path => './SmartSchool/Modules/LibTheme'
    ## CoreData
    pod 'LibCoredata',          :path => './SmartSchool/Modules/LibCoredata'
    ## 数据模型
    pod 'LibDataModel',         :path => './SmartSchool/Modules/LibDataModel'
    ## 文件上传类
    pod 'LibUpload',            :path => './SmartSchool/Modules/LibUpload'
    
    ## 模块管理类
    pod 'ModApps',              :path => './SmartSchool/Modules/ModApps'
    ## WebView
    pod 'ModWebViewStyle1',     :path => './SmartSchool/Modules/ModWebView/ModWebViewStyle1'
    
    #********************************    模块组件    **************************************#
    #************************************ 可编辑 ******************************************#
    ### 启动广告组件
    # 基类
    pod 'ModAdvertisementBase',     :path => './SmartSchool/Modules/ModAdvertisement/ModAdvertisementBase'
    # 样式一
#    pod 'ModAdvertisementStyle1',   :path => './SmartSchool/Modules/ModAdvertisement/ModAdvertisementStyle1'
    
    ### 登录组件
    # 基类
    pod 'ModLoginBase',             :path => './SmartSchool/Modules/ModLogin/ModLoginBase'
    # 样式一
    pod 'ModLoginStyle1',           :path => './SmartSchool/Modules/ModLogin/ModLoginStyle1'

#    ### 首页组件
#    # 基类
#    pod 'ModNewsBase',           :path => './SmartSchool/Modules/ModNews/ModNewsBase'
#    # 样式一
#    pod 'ModNewsStyle1',         :path => './SmartSchool/Modules/ModNews/ModNewsStyle1'
    
    ### 用户中心组件
    # 基类
    pod 'ModUserCenterBase',        :path => './SmartSchool/Modules/ModUserCenter/ModUserCenterBase'
    # 样式一
    pod 'ModUserCenterStyle1',      :path => './SmartSchool/Modules/ModUserCenter/ModUserCenterStyle1'
    
    ### 菜单组件
    # 基类
    pod 'ModMenuBase',         :path => './SmartSchool/Modules/ModMenu/ModMenuBase'
    # 样式一
    pod 'ModMenuStyle1',       :path => './SmartSchool/Modules/ModMenu/ModMenuStyle1'
    
    ### 联系人组件
    # 基类
    pod 'ModContactBase',           :path => './SmartSchool/Modules/ModContact/ModContactBase'
    # 样式一
    pod 'ModContactStyle1',         :path => './SmartSchool/Modules/ModContact/ModContactStyle1'
    
    ### 定位组件
    # 基类
    pod 'ModLocationBase',          :path => './SmartSchool/Modules/ModLocation/ModLocationBase'
    
    ### 导航组件
    # 基类
    pod 'ModNavigationBase',        :path => './SmartSchool/Modules/ModNavigation/ModNavigationBase'
    # 样式一
    pod 'ModNavigationStyle1',      :path => './SmartSchool/Modules/ModNavigation/ModNavigationStyle1'
    
    ### 分享组件
    # 基类
    pod 'ModShareBase',             :path => './SmartSchool/Modules/ModShare/ModShareBase'
    # 样式一
    pod 'ModShareStyle1',           :path => './SmartSchool/Modules/ModShare/ModShareStyle1'
    
    ### 二维码组件
    # 基类
    pod 'ModScanBase',              :path => './SmartSchool/Modules/ModScan/ModScanBase'
    # 样式一
    pod 'ModScanStyle1',            :path => './SmartSchool/Modules/ModScan/ModScanStyle1'
    
    ### 调用摄像头组件
    # 基类
    pod 'ModCameraBase',            :path => './SmartSchool/Modules/ModCamera/ModCameraBase'
    # 样式一
    pod 'ModCameraStyle1',          :path => './SmartSchool/Modules/ModCamera/ModCameraStyle1'
    
    ### 支付组件
    # 基类
    pod 'ModPayBase',               :path => './SmartSchool/Modules/ModPay/ModPayBase'
    # 样式一
    pod 'ModPayStyle1',             :path => './SmartSchool/Modules/ModPay/ModPayStyle1'
    
    ### 音视频播放组件
    # 基类
    pod 'ModPlayerBase',            :path => './SmartSchool/Modules/ModPlayer/ModPlayerBase'
    # 样式一
    pod 'ModPlayerStyle1',          :path => './SmartSchool/Modules/ModPlayer/ModPlayerStyle1'
    
    ### 天气组件
    # 基类
    pod 'ModWeatherBase',           :path => './SmartSchool/Modules/ModWeather/ModWeatherBase'
    # 样式一
    pod 'ModWeatherStyle1',         :path => './SmartSchool/Modules/ModWeather/ModWeatherStyle1'
    
    ### TTS组件
    # 基类
    pod 'ModTTSBase',               :path => './SmartSchool/Modules/ModTTS/ModTTSBase'
    # 样式一
    pod 'ModTTSStyle1',             :path => './SmartSchool/Modules/ModTTS/ModTTSStyle1'
    
    
    ### 常规检查组件
    ## 常规检查基类
    pod 'ModCommonCheckBase',       :path => './SmartSchool/Modules/ModCommonCheck/ModCommonCheckBase'
    ## 常规检查样式一
    pod 'ModCommonCheckStyle1',     :path => './SmartSchool/Modules/ModCommonCheck/ModCommonCheckStyle1'
        
    ### 录音组件
    ## 录音基类
    pod 'ModRecordBase',            :path => './SmartSchool/Modules/ModRecord/ModRecordBase'
    ## 录音样式一
    pod 'ModRecordStyle1',          :path => './SmartSchool/Modules/ModRecord/ModRecordStyle1'
end

target 'SmartSchool' do
    pods
end

# 关闭所有 taget 的 bitcode 开关
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

