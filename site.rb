require_relative './lib/site.rb'

Site.for 'drawohara.io' do
  page "/posts/:id" do
    render do
      view "posts/id"
    end

    urls do
      [1,2,3]
    end
  end
end
