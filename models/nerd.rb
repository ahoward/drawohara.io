require_relative '../config/boot.rb'

class Nerd < Site::Model
  collection_name :nerd

  def Nerd.index
    Nerd.find('index')
  end

  def index?
    id == 'index'
  end

  def url
    case
      when index?
        "/nerd"
      else
        "/nerd/#{ id }"
    end.squeeze('/')
  end

  def srcs
    Map.new.tap do |srcs|
      assets.select do |asset|
        if asset.index('/src/')
          key = './' + asset.split('/src/', 2).last
          value = asset
          srcs[key] = value
        end
      end
    end
  end
end
