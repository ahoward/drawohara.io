Site.for 'drawohara.io' do |site|
# defaults
#
  layout = 'views/layout.erb'

# home
#
  site.route '/' do |route|
    route.call do |request|
      page = Page.index
      data = page
      request.render 'views/index.erb', layout:, data:
    end
  end

# ai
#
  site.route '/ai' do |route|
    route.call do |request|
      request.render 'views/ai.erb', layout:
    end
  end

# top-level pages
#
  site.route '/:id' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("pages/#{ id }")

      if page
        request.render string: page.body.html_safe, layout:, data: page
      end
    end

    route.urls do
      Page.top_level.map do |page|
        "/#{ page.id }"
      end
    end
  end

# dojo4 archives
#
  site.route '/dojo4/archive/:id' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("dojo4/#{ id }")

      if page
        request.render string: page.body.html_safe, layout:, data: page
      end
    end

    route.urls do
      site.ro.dojo4.map{|post| "/dojo4/archive/#{ post.id }"}
    end
  end

  site.route '/dojo4' do |route|
    route.call do |request|
      posts = site.ro.dojo4.sort_by{|post| post.published_at}.reverse
      ara, dojo4 = posts.partition{|post| post.author == 'ara@dojo4.com'}
      data = {ara:, dojo4:}
      request.render 'views/dojo4.erb', layout:, data:
    end
  end

# big fat list of everything
#
  site.route '/goto' do |route|
    route.call do |request|
      urls = site.urls
      data = {urls:}
      request.render 'views/goto.erb', layout:, data:
    end
  end

# purls
#
  site.route '/purl/:id' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      purl = site.ro.get("purl/#{ id }")

      if purl
        request.render 'views/purl.erb', data: purl
      end
    end

    route.urls do
      site.ro.purl.map{|purl| "/purl/#{ purl.id }"}
    end
  end

# random deeply nested pages...
#
  site.route '**/**' do |route|
    route.call do |request|
      path_info = request.params.fetch(:path_info)
    end

    route.urls do
      Page.other.map do |page|
        "/#{ page.path_info }"
      end
    end
  end
end
