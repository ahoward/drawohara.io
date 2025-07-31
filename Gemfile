# frozen_string_literal: true

source "https://rubygems.org"

# FIXME - ruby is moving lots of shit out of stdlib like crazy and bleats fugly warnings ;-/
#
gem "rdoc"
gem "fiddle"
gem "webrick", "~> 1.9.1"
gem "logger"
gem "ostruct"

%w[
  ro
  map
  rego
].each do |lib|
  #if test(?e, File.expand_path("~/gh/ahoward/#{ lib }"))
    #gem "#{ lib }", path: "~/gh/ahoward/#{ lib }"
  #else
    gem "#{ lib }", git: "https://github.com/ahoward/#{ lib }"
  #end
end

gem "dotenv"

gem "listen"
gem "rack"
gem "rackup"
gem "puma"
#gem "thruster"

gem "parallel"
gem "mistral-ai"
gem "groq"
gem "anthropic"
gem "lockfile"

