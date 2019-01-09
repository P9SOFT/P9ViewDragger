Pod::Spec.new do |s|

  s.name         = "P9ViewDragger"
  s.version      = "1.2.0"
  s.summary      = "Developers can easily implement dragging view function with P9ViewDragger."
  s.homepage     = "https://github.com/P9SOFT/P9ViewDragger"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/P9SOFT/P9ViewDragger.git", :tag => "1.2.0" }
  s.source_files  = "Sources/*.{h,m}"
  s.public_header_files = "Sources/*.h"

end
