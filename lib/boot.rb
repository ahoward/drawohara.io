boot = File.expand_path(__FILE__)
lib = File.dirname(boot)
root = File.dirname(lib)
config = File.join(root, 'config')

Dir.chdir(root) do
  require "bundler/setup"

  require "#{ lib }/site.rb"

  Dir.glob("#{ root }/models/**/**.rb").each{|model| require(model)}

  require "#{ config }/site.rb"
end
