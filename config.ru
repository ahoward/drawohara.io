Dir.chdir(File.dirname(__FILE__))

require_relative './lib/site.rb'

config = File.expand_path(File.join(Dir.pwd, './site.rb'))

if test(?e, config)
  require_relative(config)
else
  abort "no site in #{ config }"
end

site = Site.default

freeze_app

run(site.server)