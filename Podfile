#xcodeproj '../DropboxPhotoTest.xcodeproj'

# Uncomment this line to define a global platform for your project
# Uncomment this line if you're using Swift
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'

target 'DropboxPhotoTest' do
    #platform :ios, '9.1'
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
                config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
            end
        end
    end

    pod 'Firebase/Core'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'SwiftyJSON'
    #pod 'JSONHelper'
    #pod 'SwiftyDropbox'
    pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift', :branch => 'feature/swift-3'
    #pod 'SwiftPhotoGallery'

    pod 'Instabug'
    pod 'MWPhotoBrowser'
    
    
end
