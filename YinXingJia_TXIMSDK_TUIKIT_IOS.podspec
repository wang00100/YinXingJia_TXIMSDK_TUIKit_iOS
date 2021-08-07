#
#  Be sure to run `pod spec lint YinXingJia_TXIMSDK_TUIKit_iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "YinXingJia_TXIMSDK_TUIKit_iOS"
  spec.version      = "0.1.4"
  spec.summary      = "YinXingJia_TXIMSDK_TUIKit_iOS"


  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = "补充语言文件"

  spec.homepage     = "https://github.com/wang00100/YinXingJia_TXIMSDK_TUIKit_iOS"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"



  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  #spec.license      = "MIT (example)"
  spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "Vince" => "190265384@qq.com" }
  # Or just: spec.author    = "Cxiaoyu08"
  # spec.authors            = { "Cxiaoyu08" => "755678068@qq.com" }
  # spec.social_media_url   = "https://twitter.com/Cxiaoyu08"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "9.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files = 'TUIKit/Classes/**/*.{h,m,mm,swift}'
  spec.vendored_libraries = ['TUIKit/Classes/third/voiceConvert/opencore-amrnb/libopencore-amrnb.a', 'TUIKit/Classes/third/voiceConvert/opencore-amrwb/libopencore-amrwb.a']
  spec.resource = ['TUIKit/Resources/TUIKitFace.bundle','TUIKit/Resources/TUIKitResource.bundle','TUIKit/Resources/Localizable/zh-Hans.lproj','TUIKit/Resources/Localizable/en.lproj']

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
  spec.libraries    = 'stdc++'

  spec.dependency 'MMLayout','0.2.0'
  spec.dependency 'SDWebImage','5.9.0'
  spec.dependency 'ReactiveObjC','3.1.1'
  spec.dependency 'Toast','4.0.0'
  spec.dependency 'ISVImageScrollView','0.1.2'
  spec.dependency 'AFNetworking','4.0.1'
  spec.dependency 'SnapKit','4.2.0'
  spec.dependency 'Toast-Swift','5.0.1'
  spec.dependency 'RxSwift','5.1.1'
  spec.dependency 'RxCocoa','5.1.1'
  spec.dependency 'NVActivityIndicatorView','4.8.0'
  spec.dependency 'Material','3.1.8'
  spec.dependency 'Alamofire','5.4.1'
  spec.dependency 'TXLiteAVSDK_TRTC','7.8.9519'
  spec.dependency 'TXIMSDK_iOS','5.1.56'
  # spec.dependency 'TZImagePickerController'

  spec.swift_version = '5.0'

end
