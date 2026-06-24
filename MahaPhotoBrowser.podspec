Pod::Spec.new do |s|
  s.name                  = 'MahaPhotoBrowser'
  s.version               = '0.1.1'
  s.summary               = 'A private photo browser and picker component used by the app.'

  s.description           = <<-DESC
                              MahaPhotoBrowser repackages the existing ZLPhotoBrowser implementation
                              into a private pod and exposes renamed public APIs for the app.
                              DESC

  s.homepage              = 'https://github.com/wangweiqi864-hue/MahaPhotoBrowser'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'wangweiqi864-hue' => 'wangweiqi864-hue@users.noreply.github.com' }
  s.source                = { :git => 'https://github.com/wangweiqi864-hue/MahaPhotoBrowser.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.swift_versions        = ['5.0', '5.1', '5.2']
  s.requires_arc          = true
  s.frameworks            = 'UIKit', 'Photos', 'PhotosUI', 'AVFoundation', 'CoreMotion', 'Accelerate'

  s.resources             = 'MahaPhotoBrowser/Sources/*.{png,bundle}'
  s.resource_bundles      = { 'MahaPhotoBrowser_Privacy' => ['MahaPhotoBrowser/Sources/PrivacyInfo.xcprivacy'] }

  s.subspec 'Core' do |sp|
    sp.source_files       = ['MahaPhotoBrowser/Sources/**/*.{swift,h,m}', 'MahaPhotoBrowser/Sources/MahaPhotoBrowser.h']
    sp.exclude_files      = ['MahaPhotoBrowser/Sources/General/MahaWeakProxy.swift']
  end
end
