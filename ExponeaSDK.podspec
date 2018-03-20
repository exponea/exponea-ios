Pod::Spec.new do |s|
  s.name             = "ExponeaSDK"
  s.version          = "1.0.1"
  s.summary          = "Exponea SDK for iOS."
  s.homepage         = "https://github.com/exponea/exponea-ios"
  s.license          = { :type => "Copyright", :text => 'Lorem ipsum dolorem sit amet...' }
  s.author           = { "Exponea" => "info@exponea.com" }
  s.source           = { :http => "https://github.com/exponea/exponea-ios.git", :tag => '1.0.1' }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files        = ['ExponeaLibSDK/*.h', 'ExponeaLibSDK/*.m', 'ExponeaSDK/*.h', 'ExponeaSDK/*.m']
  s.public_header_files = ['ExponeaLibSDK/*.h']

  s.frameworks = 'Foundation'
  s.library = 'sqlite3'
  s.vendored_frameworks = "ExponeaSDK.framework"
end
