require 'securerandom'
require 'tmpdir'
require 'fileutils'

require 'ro'
require 'parallel'

require_relative 'server.rb'

class Site
#
  REGISTRY = {}

  def Site.registry
    REGISTRY
  end

  def Site.for(*args, **kws, &block)
    if block
      new(*args, **kws, &block).tap do |site|
        Site.registry[site.name] = site
      end
    else
      name = (args.first || :default)
      Site.registry.fetch(name, &block)
    end
  end

  def Site.only
    Site.registry.values.last if Site.registry.size == 1
  end

  def Site.default
    Site.only || Site.registry.fetch(:default)
  end

  def Site.get(...)
    only.get(...)
  end

#
  attr_reader :name
  attr_reader :domain
  attr_reader :server
  attr_reader :ro

  def initialize(*args, **kws, &block)
    @name = kws.fetch(:name){ args.shift || :default }

    @domain = kws.fetch(:domain){ args.shift || @name }.to_s

    @server = Server.new

    block.call(self) if block

    @ro = Ro::Root.new('./public/ro')
  end

  def inspect
    @name.inspect
  end

  def route(*args, **kws, &block)
    kws[:site] = self
    @server.route(*args, **kws, &block)
  end

  def routes
    @server.routes
  end

  def get(path = '/')
    @server.get(path)
  end

  def urls(&block)
    if block
      routes.each do |route|
        route.urls.each do |url|
          block.call(url)
        end
      end
    else
      Parallel.map(routes, in_threads: 8) do |route|
        route.urls
      end.tap do |urls|
        urls.flatten!
        urls.compact!
        urls.uniq!
      end
    end
  end
end
