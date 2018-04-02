source 'https://github.com/socialize/SocializeCocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

pod 'Loopy', '1.1.3'

pod  'Facebook-iOS-SDK', :path => "/Users/alocorn/Documents/Projects/CustomPods/facebook-ios-sdk"

pod 'Bolts', '1.8.4'
pod 'BlocksKit'
pod 'SZOAuthConsumer', :podspec => 'https://raw.github.com/socialize/OAuthConsumer/master/SZOAuthConsumer.podspec'
pod 'SZJSONKit', :podspec => 'https://raw.github.com/socialize/JSONKit/master/SZJSONKit.podspec'
#pod 'Pinterest-iOS', '2.3'
pod 'STTwitter', '0.2.6'

target 'Socialize' do

end

target 'UIIntegrationAcceptanceTests' do
  pod 'KIF', '2.0.0'
end

target 'UnitTests' do
  pod 'Socialize', :path => './'
end

post_install do | installer |
  #copy resources from Loopy to include in framework
  require 'fileutils'
  FileUtils.cp_r(Dir['Pods/Loopy/Loopy/Resources/*'], 'Socialize/Resources', :remove_destination => true)
  FileUtils.cp_r('Pods/Loopy/Loopy/LoopyApiInfo.plist', 'Socialize/Resources', :remove_destination => true)


end
