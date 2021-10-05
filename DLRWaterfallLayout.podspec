#
# Be sure to run `pod lib lint DLRWaterfallLayout.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DLRWaterfallLayout"
  s.version          = "0.1.0"
  s.summary          = "A Waterfall Collection View Layout"
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/DLRWaterfallLayout"
  s.license          = 'MIT'
  s.author           = { "Mark Schall" => "mark@detroitlabs.com",
                         "Nathan Walczak" => "nate.walczak@detroitlabs.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/DLRWaterfallLayout.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DLRWaterfallLayout' => ['Pod/Assets/*.png']
  }
end
