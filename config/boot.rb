boot = File.expand_path(__FILE__)
root = File.dirname(File.dirname(boot))

lib = File.join(root, 'lib')
config = File.join(root, 'config')

require "bundler/setup"

require "#{ lib }/site.rb"
require "#{ config }/site.rb"

Dir.glob("#{ root }/models/**/**.rb").each{|model| require(model)}
