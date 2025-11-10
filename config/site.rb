Site.for 'drawohara.io' do |site|
  site.layout = './views/layout-minimal.erb'

# /
#
  site.route '/' do |route|
    route.call do |ctx|
      data = Page.index
      ctx.render string: data.body, data:
    end
  end

# /ai
#
  site.route '/ai' do |route|
    route.call do |ctx|
      ctx.render 'views/ai.erb.md'
    end
  end

# /quotes
#
  site.route '/quotes' do |route|
    route.call do |ctx|
      ctx.render 'views/quotes.erb'
    end
  end

# /rubygems
#
  site.route '/rubygems' do |route|
    route.call do |ctx|
      ctx.render 'views/rubygems.erb'
    end
  end

# /langs
#
  site.route '/langs' do |route|
    route.call do |ctx|
      langs = site.dato.fetch(:langs)
      data = {langs:}
      ctx.render 'views/langs.erb', data:
    end
  end

# /io
#
  site.route '/io/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      page = site.ro.get("io/#{ id }")

      if page
        ctx.render string: page.body.html_safe, data: page
      end
    end

    route.urls do
      site.ro.io.map{|post| "/io/#{ post.id }"}
    end
  end

  site.route '/io' do |route|
    route.call do |ctx|
      data = Content.index
      ctx.render 'views/io/index.erb', data:
    end
  end

# /nerd
#
  site.route '/nerd' do |route|
    route.call do |ctx|
      nerd = Nerd.index
      index = Nerd.all - [nerd]
      data = {nerd:, index:}.update(nerd) #FIXME cuz og:
      ctx.render 'views/nerds.erb', data:
    end
  end

  site.route '/nerd/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      nerd = Nerd.find(id)

      if nerd
        ctx.render 'views/nerd.erb', data:nerd
      end
    end

    route.urls do
      site.ro.nerd.map{|nerd| "/nerd/#{ nerd.id }"}
    end
  end

# dojo4 archives
#
  site.route '/dojo4/archive/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      page = site.ro.get("dojo4/#{ id }")

      if page
        ctx.render 'views/dojo4-archive.erb', data:page
      end
    end

    route.urls do
      site.ro.dojo4.map{|post| "/dojo4/archive/#{ post.id }"}
    end
  end

  site.route '/dojo4' do |route|
    route.call do |ctx|
      posts = site.ro.dojo4.sort_by{|post| post.published_at}.reverse
      ara, dojo4 = posts.partition{|post| post.author == 'ara@dojo4.com'}
      data = {ara:, dojo4:}
      ctx.render 'views/dojo4.erb', data:
    end

    route.urls do
      %w[ /dojo4 ] # FIXME
    end
  end

# /goto
#
  site.route '/goto' do |route|
    route.call do |ctx|
      urls = %w[ /now /io /nerd /about /purls /quotes /dojo4 /sitemap ]
      data = {urls:}
      ctx.render 'views/goto.erb', data:
    end
  end

# /sitemap
#
  site.route '/sitemap' do |route|
    route.call do |ctx|
      urls = site.urls
      data = {urls:}
      ctx.render 'views/sitemap.erb', data:
    end
  end

# purls
#
  site.route '/purls/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)

      unless id =~ /^[0-9]$/
        purl = site.ro.purls.get(id)

        if purl
          ctx.render 'views/purl.erb', data: purl
        end
      end
    end

    route.urls do
      site.ro.purls.to_a.reverse.map{|purl| "/purls/#{ purl.id }"}
    end
  end

  site.route '/purls' do |route|
    route.call do |ctx|
      purls = site.ro.purls
      data = {purls:}
      ctx.render 'views/purls.erb', data:
    end
  end

# top-level purls
#
  site.route '/:id' do |route|
    route.call do |ctx|
      id = ctx.params[:id]

      if id =~ /^[0-9]$/
        purl = site.ro.purls.get(id)

        if purl
          ctx.render 'views/purl.erb', data: purl
        end
      end
    end

    route.urls do
      site.ro.purls.map{|purl| "/purls/#{ purl.id }"}
    end
  end

# top-level pages
#
  site.route '/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      page = site.ro.get("pages/#{ id }")

      if page
        ctx.render string: page.body, data: page
      end
    end

    route.urls do
      Page.top_level.map do |page|
        "/#{ page.id }"
      end
    end
  end

# /m (microblog)
#
  site.route '/m' do |route|
    route.call do |ctx|
      # Load all microblog entries
      entries = []

      Dir.glob('public/ro/microblog/*.yml').each do |path|
        begin
          # Load YAML frontmatter
          yaml = YAML.safe_load_file(path, permitted_classes: [Time, Date], aliases: true)

          # Parse timestamp
          yaml['timestamp'] = Time.parse(yaml['timestamp'].to_s) if yaml['timestamp']

          # Get slug from filename
          slug = File.basename(path, '.yml')

          # Read body from slug/body.md
          body_path = File.join('public/ro/microblog', slug, 'body.md')
          yaml['body'] = File.read(body_path) if File.exist?(body_path)

          entries << Map.for(yaml)
        rescue => e
          warn "Skipping #{path}: #{e.message}"
        end
      end

      # Sort newest first
      entries = entries.sort_by { |e| e['timestamp'] }.reverse

      ctx.render 'views/microblog.erb', data: { entries: }
    end

    route.urls do
      %w[ /m ]
    end
  end

# nested pages
#
  site.route '**/**' do |route|
    route.call do |ctx|
      path_info = ctx.params.fetch(:path_info)
    end

    route.urls do
      Page.other.map do |page|
        "/#{ page.path_info }"
      end
    end
  end

# site.helpers
#
  require_relative '../lib/helpers'
  site.utils << Helpers
end
