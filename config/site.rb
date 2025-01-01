require_relative "../lib/site.rb"

Site.for 'drawohara.io' do |site|
#
  site.route '/', name: 'root' do |route|
    route.call do |request|
      page = site.ro.get('pages/index')
      request.render 'views/index.erb', layout: 'views/layout.erb', data: page
    end
  end

#
  site.route '/:id', name: 'page' do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("pages/#{ id }")
      request.render string: page.body.html_safe, layout: 'views/layout.erb', data: page
    end

    route.urls do
      site.ro.pages.map do |page|
        id = page.id
        path_info = page.get(:path_info) || page.get(:path)

        next if id == 'index'
        next if path_info

        "/#{ id }"
      end.compact
    end
  end

#
  site.route '**', name: 'catchall' do |route|
    route.call do |request|
      path_info = request.params.fetch(:path_info)
    end

    route.urls do
      "/foo/bar/baz"
    end
  end
end
