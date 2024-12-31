require_relative "./lib/site.rb"

Site.for 'drawohara.io' do |site|
#
  site.route "/" do |route|
    route.call do |request|
      page = site.ro.get("pages/index")
      request.render 'views/index.erb', layout: 'views/layout.erb', data: page
    end
  end

#
  site.route "/:id" do |route|
    route.call do |request|
      id = request.params.fetch(:id)
      page = site.ro.get("pages/#{ id }")
      request.render string: page.body.html_safe, layout: 'views/layout.erb', data: page
    end

    route.urls do
      site.ro.pages.map(&:id) - %w[ index ]
    end
  end

#
  #site.route "**" do |route|
    #route.render do |params|
      #"**" # need a 404...
    #end
  #end
end
