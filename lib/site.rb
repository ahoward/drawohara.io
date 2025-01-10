require 'securerandom'
require 'tmpdir'
require 'fileutils'

require 'ro'
require 'parallel'

require_relative 'site/server.rb'
require_relative 'site/dato.rb'
require_relative 'site/model.rb'

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
  attr_reader :root
  attr_reader :ro
  attr_reader :dato
  attr_reader :server

  attr_accessor :layout

  def initialize(*args, **kws, &block)
    @name = kws.fetch(:name){ args.shift || :default }

    @domain = kws.fetch(:domain){ @name }.to_s

    @root = Path.for(kws.fetch(:root){ '.' })

    @ro = Ro::Root.new(path_for('./public/ro'))

    @dato = Dato.load(path_for('./dato'))

    @layout = path_for(kws.fetch(:layout){ './views/layout.erb' })

    @server = Server.new(site: self)

    block.call(self) if block
  end

  def path_for(...)
    @root.join(...)
  end

  def inspect
    @name.inspect
  end

  def route(...)
    @server.route(...)
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
      urls =
        Parallel.map(routes, in_threads: 8) do |route|
          route.urls
        end.tap do |list|
          list.flatten!
          list.compact!
          list.uniq!
        end

      urls.sort do |a, b|
        x = Path.for(a).parts
        y = Path.for(b).parts

        case
          when x.size == y.size
            a <=> b
          else
            x.size <=> y.size
        end
      end
    end
  end

  def url_for(arg, *args, **kws, &block)
    case arg
      when Symbol
        route_url_for(arg, *args, **kws, &block)
      else
    end
  end
end
