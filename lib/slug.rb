#! /usr/bin/env ruby
# encoding: utf-8

class Slug < ::String
  Join = '-'

  def Slug.for(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    join = (options[:join] || options['join'] || Join).to_s

    string = args.flatten.compact.join(' ')

    tokens = string.scan(%r`[^\s#{ join }]+`)

    tokens.map! do |token|
      token.gsub(%r`[^[0-9]\p{L}/.]`, '').downcase
    end

    tokens.map! do |token|
      token.gsub(%r`[/.]`, join * 2)
    end

    tokens.join(join)
  end
end

if $0 == __FILE__
  ARGV.each do |arg|
    puts Slug.for(arg)
  end
end
