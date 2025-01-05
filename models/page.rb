require_relative '../lib/model.rb'

class Page < Model
  collection_name :pages

  def Page.index
    Page.find('index')
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
    get(:path_info).nil? && id != 'index'
  end

  def other?
    get(:path_info) && id != 'index'
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
