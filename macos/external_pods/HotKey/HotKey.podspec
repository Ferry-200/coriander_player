Pod::Spec.new do |s|
  s.name             = 'HotKey'
  s.version          = '0.1.8'
  s.summary          = 'Global hot keys for macOS applications.'
  s.description      = <<-DESC
    HotKey is a Swift framework for registering global hot keys for macOS applications.
                       DESC
  s.homepage         = 'https://github.com/soffes/HotKey'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sam Soffes' => 'sam@soff.es' }
  s.source           = { :path => '.' }
  s.social_media_url = 'https://twitter.com/soffes'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.swift_version = '5.0'
  s.source_files = 'Sources/**/*'
  s.frameworks = 'Carbon'
end