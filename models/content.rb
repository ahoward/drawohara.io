require_relative '../config/boot.rb'

class Content
  def Content.ro
    Ro.root
  end

  def Content.types
    [:io, :nerd, :purls]
  end

  def Content.sort(list)
    list.sort_by(&:updated_at).reverse
  end

  def Content.for_type(type)
    nodes = ro.collections[type]
    nodes.map{|node| Content.new(type, node) unless node.id == 'index'}.compact
  end

  def Content.index
    Map.new.tap do |index|
      Content.types.each do |type|
        list = Content.for_type(type)
        next if list.empty?
        index[type] = list
      end
    end
  end

  attr_accessor :type, :node

  def initialize(type, node)
    @type = type
    @node = node
  end

  def method_missing(name, *args, &block)
    raise unless node.respond_to?(name)
    node.send(name, *args, &block)
  end

  def index?
    id == 'index'
  end

  def url
    ["/#{ type }", (id unless index?)].compact.join("/")
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
