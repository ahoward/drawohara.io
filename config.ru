#
  Dir.chdir(File.dirname(__FILE__))

  require_relative './lib/boot.rb'

#
  site = Site.default

#
  ENV['HOST'] ||= '0.0.0.0'
  ENV['PORT'] ||= '4242'

  freeze_app

  run(site.server)
