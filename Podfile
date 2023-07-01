# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'Will Robots Take Over the World Today?' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for Will Robots Take Over the World Today?
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Hero'
  
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      end
    end
  end
end
