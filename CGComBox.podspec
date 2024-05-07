

Pod::Spec.new do |s|

  s.name         = "CGComBox"
  s.version      = "1.3.9"
  s.ios.deployment_target = '12.0'
  s.summary            = "一个下拉多选的自定义控件CGComBox"
  s.homepage           = "https://github.com/y1503/CGComBox-github"
  s.license            = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "鱼鱼" => "y1503@126.com" }
  s.social_media_url   = "http://weibo.com/u/3271812005"

  s.platform           = :ios, '12.0'

  s.source             = { :git => "https://github.com/y1503/CGComBox-github.git", :tag => s.version }

  s.source_files       = "CGComBoxKit/Classes/*.{h,m}"
  
  s.resource_bundles = {
   'CGComBoxBundle' => ['CGComBoxKit/Resources/*']
}

 	s.frameworks         = 'Foundation', 'UIKit'

  s.requires_arc       = true

  s.dependency "Masonry"
end
