require_relative "./lib/site.rb"

Site.for 'https://drawohara.io' do |site|
#
  site.route "/" do |route|
    route.render do |params|
      @c = site.ro.get("pages/index")
      view inline: @c.body
    end

    route.urls do
      %w[ / ]
    end
  end

#
  site.route "/:id" do |route|
    route.render do |params|
      id = params.fetch(:id)
      @c = site.ro.get("pages/#{ id }")
      view inline: @c.body
    end

    route.urls do
      site.ro.pages.map(&:id) - %w[ index ]
    end
  end
end
