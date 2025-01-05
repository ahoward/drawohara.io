# frozen_string_literal: true

source "https://rubygems.org"

# FIXME - ruby is moving lots of shit out of stdlib like crazy and bleats
# fugly warnings ;-/
gem "rdoc"
gem "fiddle"
gem "webrick", "~> 1.9.1"
gem "logger"
gem "ostruct"

# prefer local ro dep
if test(?e, File.expand_path('~/gh/ahoward/ro'))
  gem "ro", path: '~/gh/ahoward/ro'
else
  gem "ro", git: 'https://github.com/ahoward/ro'
end

gem "rack"
gem "rackup"
gem "puma"
#gem "thruster"

gem "ak47"
gem "map"
gem "parallel"

