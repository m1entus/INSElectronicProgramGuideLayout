Pod::Spec.new do |s|
  s.name     = 'INSElectronicProgramGuideLayout'
  s.version  = '1.0.0'
  s.license  = 'BSD'
  s.summary  = 'UICollectionViewLayout for displaying electronic program guide.'
  s.homepage = 'http://inspace.io'
  s.authors  = 'inspace.io'
  s.source   = { :git => 'https://github.com/inspace-io/INSElectronicProgramGuideLayout.git', :tag => '1.0.0' }
  s.source_files = 'INSElectronicProgramGuideLayout/*.{h,m}'
  s.requires_arc = true

  s.platform = :ios, '7.0'
  s.frameworks = 'UIKit'
end