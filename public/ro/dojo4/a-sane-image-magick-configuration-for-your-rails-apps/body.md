i've often said that file uploads are a self inflicted DOS attack.  certainly one doesn't have to look far to find examples of a seemingly small app feature wreaking havoc on many an app server: https://www.google.com/search?q=heroku+image+magick+timed+out

@dojo4 we use image magicks ability to set limts via the environment as first line of defense to keep magick processes well behaved.

first a little setup/background:  we often deploy a RAILS_ROOT/env.yml and RAILS_ROOT/env.rb file pair that the rails application will slurp in on boot.  they contain no rails deps and can be used in background scripts to quickly understand the deployed rails configuration without needing to load the entire rails applicaion.

the first file is a simple yaml file of k=v env pairs.

````ruby


# file: RAILS_ROOT/config/env.yml


# RAILS_ENV      : production

# RAILS_STAGE : stage

# APP_RUBY   : /usr/local/rbenv/versions/1.9.3-p0/bin/ruby

APP_RUBY_VERSION : 1.9.3

# APP_PORT   : 4201

# APP_USER   : dojo4

# APP_GROUP  : dojo4


````

the second is actually the file that's required.  it loads this file and has a dynamic whack at setting further environment variables


````ruby

# file: RAILS_ROOT/env.rb
#
# first, we fold in any environment settings found in 
#
#   RAILS_ROOT/env.yml
#
# being careful not to clobber any manually set ENV vars.  the env.yml file is
# normally created during a cap deployment.
# 
  require 'erb'
  require 'yaml'
  require 'rbconfig'
  
  env_yml = File.expand_path('../env.yml', __FILE__)
  
  if test(?s, env_yml)
    buf = IO.read(env_yml)
    expanded = ERB.new(buf).result(binding)
    config = YAML.load(expanded)
    config.each{|key, val| ENV[key.to_s] ||= val.to_s} if config.is_a?(Hash)
  end


````

what we're interested in here is the section in which the imagemagick environment is configured.

here it is in all its full glory - the comments should provide context and explanation:

````ruby
# ensure RAILS_* are set
#
  ENV['RAILS_ENV'] ||= 'development'
  ENV['RAILS_ROOT'] ||= File.dirname(File.dirname(__FILE__))

# set Imagick Magick environment
#
# ref: http://www.imagemagick.org/script/resources.php
#
# use system "convert -list resource" in the console to view
#
# realize that these settings are *per-process* so multiple times the number
# of app servers you have running!
#
  tmp = File.join(ENV['RAILS_ROOT'], 'tmp')

# keep your temp files out of system space, which on AWS is part of the root
# volume!
#
  ENV['TMPDIR']              = tmp
  ENV['MAGICK_TMPDIR']       = tmp

# keep only this many open file handles at a time
#
  ENV['MAGICK_FILE_LIMIT']   = 64

# width * height < this value fits in memory.  otherwise it uses the pixel
# cache
#
  ENV['MAGICK_AREA_LIMIT']   = '64MB'

# don't eat more than this much memory
#
  ENV['MAGICK_MEMORY_LIMIT'] = '256MiB'

# don't map more than this much memory
#
  ENV['MAGICK_MAP_LIMIT']    = '1GiB'

# eat less than this much disk total
#
  ENV['MAGICK_DISK_LIMIT']   = '64GiB'

# flush writes to disk more often
#
  ENV['MAGICK_SYNCHRONIZE']  = true

# yield the cpu in chunks of this many ms
#
  ENV['MAGICK_THROTTLE']     = 256

# 8 minutes out to be long to enough to re-size a damn image...
#
  ENV['MAGICK_TIME_LIMIT'] = 8 * 60


````


salt to taste because now you are aware that the behavior of your image resizing processes is within your own control, and you can use this to gaurd against crazy resource allocation.

