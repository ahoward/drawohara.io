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

  def get(...)
    @server.get(...).check!
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
      end.flatten
    end
  end

#
  def build(dir: './build', clean: true, parallel: 8, quiet: false)
    site = self

    Site.clean!(dir) if clean

    FileUtils.mkdir_p(dir)

    build = proc do |url|
      response = get(url)

      file = "#{ url == '/' ? '/index' : url }.html"
      path = File.join(dir, file)

      abort "url=#{ url }, path=#{ path } exists in #{ dir }" if test(?e, path)

      Site.binwrite(path, response)

      $stderr.puts("#{ url } -> #{ dir }#{ file }") unless quiet
    end

    a = Time.now.to_f
    urls = site.urls.uniq
    n = urls.size

    if parallel
      Parallel.each(urls, in_processes: parallel) do |url|
        build[url]
      end
    else
      urls.each do |url|
        build[url]
      end
    end

    b = Time.now.to_f
    e = (b - a).round(2)

    unless quiet
      $stderr.puts("---")
      $stderr.puts("#{ n } in #{ e }s")
      $stderr.puts("")
    end

    dir
  end

  def Site.clean!(dir)
    if test(?d, dir)
      trash = Site.tmpdir
      FileUtils.mv(dir, trash)

      fork do
        FileUtils.rm_rf(trash)
        exit!
      end
    end
  end

  def Site.tmpdir(&block)
    uuid = SecureRandom.uuid_v7
    dir = File.join('./tmp', uuid)
    FileUtils.mkdir_p(dir)
    dir
  end

  def Site.binwrite(path, data)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless test(?e, dirname)
    IO.binwrite(path, data)
  end
end
