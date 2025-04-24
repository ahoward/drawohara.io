require_relative '../config/boot.rb'

class Page < Site::Model
  collection_name :pages

  Routes = {
    '/'        => :index,
    '/about'   => :about,
    '/contact' => :contact,
    '/disco'   => :disco,
    '/now'     => :now,
  }

  def Page.routes
    Routes
  end

  def Page.route(path_info)
    name = Page.routes.fetch(path_info)

    Page.find(name)
  end

  Routes.each do |path_info, name|
    define_singleton_method(name) do
      Page.route(path_info)
    end
  end

  def Page.top_level
    Page.all.select{|page| page.top_level?}
  end

  def Page.other
    Page.all.select{|page| page.other?}
  end

  def index?
    id == 'index'
  end

  def top_level?
    get(:path_info).nil? &&
    id != 'index'
  end

  def other?
    get(:path_info) &&
    id != 'index'
  end

  def url
    case
      when top_level?
        "/#{ id }"
      when other?
        "/#{ path_info }"
      when index?
        "/"
    end.squeeze('/')
  end
end
