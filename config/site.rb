require_relative "../lib/site.rb"
require_relative '../models/page.rb'

Site.for 'drawohara.io' do |site|
# defaults
#
  layout = 'views/layout.erb'

# dojo4 shit
#
  site.route '/dojo4/archive/:id' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("dojo4/#{ id }")
      data = page
      request.render string: page.body.html_safe, layout:, data:
    end

    route.urls do
      site.ro.dojo4.map{|post| "/dojo4/archive/#{ post.id }"}
    end
  end

  site.route '/dojo4' do |route|
    route.call do |request|
      posts = site.ro.dojo4.sort_by{|post| post.published_at}.reverse
      ara, dojo4 = [], []

      posts.each do |post|
        if post.author == 'ara@dojo4.com'
          ara << post
        else
          dojo4 << post
        end
      end

      data = {ara:, dojo4:}

      request.render 'views/dojo4.erb', layout:, data:
    end

    route.urls do
      '/dojo4'
    end
  end

# top-level pages
#
  site.route '/:id', name: 'page' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("pages/#{ id }")
      data = page
      request.render string: page.body.html_safe, layout:, data:
    end

    route.urls do
      Page.top_level.map do |page|
        "/#{ page.id }"
      end
    end
  end

# home
#
  site.route '/', name: 'root' do |route|
    route.call do |request|
      page = Page.index
      data = page
      request.render 'views/index.erb', layout:, data:
    end
  end

# ...
#
  site.route '**', name: 'catchall' do |route|
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
