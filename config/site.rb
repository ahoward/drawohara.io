Site.for 'drawohara.io' do |site|
# /home
#
  site.route '/' do |route|
    route.call do |ctx|
      page = Page.index
      data = page
      ctx.render 'views/index.erb', data:
    end
  end

# /ai
#
  site.route '/ai' do |route|
    route.call do |ctx|
      ctx.render 'views/ai.erb'
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

# /io/story
#
=begin
  site.route '/io/story/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      page = site.ro.get("story/#{ id }")

      if page
        ctx.render string: page.body.html_safe, data: page
      end
    end

    route.urls do
      site.ro.io.map{|post| "/io/story/#{ post.id }"}
    end
  end

  site.route '/io/story' do |route|
    route.call do |ctx|
      index = site.ro.story
      data = {index:}
      ctx.render 'views/story.erb', data:
    end
  end
=end

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
      index = site.ro.io
      data = {index:}
      ctx.render 'views/io.erb', data:
    end
  end

# /nerd
#
  site.route '/nerd' do |route|
    route.call do |ctx|
      ctx.render string: 'coming soon! 🤓'
    end
  end

# /stream
#
  site.route '/stream' do |route|
    route.call do |ctx|
      ctx.render string: 'coming soon? i dunno... perhaps there is enough ;-/'
    end
  end

# dojo4 archives
#
  site.route '/dojo4/archive/:id' do |route|
    route.call do |ctx|
      id = ctx.params.fetch(:id)
      page = site.ro.get("dojo4/#{ id }")

      if page
        data = {page:}
        ctx.render 'views/dojo4-archive.erb', data:
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
  end

# /goto
#
  site.route '/goto' do |route|
    route.call do |ctx|
      urls = %w[ /io /nerd /purls /langs /dojo4 /sitemap /home ]
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
        ctx.render string: page.body.html_safe, data: page
      end
    end

    route.urls do
      Page.top_level.map do |page|
        "/#{ page.id }"
      end
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
end
