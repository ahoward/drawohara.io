require 'ro'
require 'map'

require_relative 'pagination'

class Site
  class Model
    class << Model
      include Enumerable

      def root
        @root ||= Ro.root
      end

      def root=(root)
        @root = Ro::Root.for(root)
      end

      def default_collection_name
        name.to_s.split(/::/).last
      end

      def collection_name(collection_name = nil)
        @collection_name = collection_name.to_s if collection_name

        @collection_name || default_collection_name
      end

      def collection
        root.collections[collection_name]
      end

      def each(offset: nil, limit: nil, &block)
        if block_given?
          collection.each(offset:, limit:) do |node|
            yield new(node)
          end
        else
          Enumerator.new do |yielder|
            collection.each(offset:, limit:) do |node|
              yielder << new(node)
            end
          end
        end
      end

      def all
        if block_given?
          each do |model|
            yield model
          end
        else
          list
        end
      end

      def list
        List.for to_a
      end

      def paginate(size:10, &block)
        if block_given?
          collection.paginate(size:) do |nodes|
            page = nodes.map { |node| new(node) }
            yield page
          end
        else
          Enumerator.new do |yielder|
            collection.paginate(size:) do |nodes|
              page = nodes.map { |node| new(node) }
              yield page
              yielder << page
            end
          end
        end
      end

      def select(*args, &block)
        to_a.select(*args, &block)
      end

      def detect(*args, &block)
        to_a.detect(*args, &block)
      end

      def count(*args, &block)
        if args.empty? and block.nil?
          collection.size
        else
          where(*args, &block).size
        end
      end

      def where(*_args, &block)
        to_a.select do |model|
          !!model.instance_eval(&block)
        end
      end

      def first
        new(collection.first)
      end

      def last
        new(collection.last)
      end

      def find(id)
        id = id.to_s
        to_a.detect { |model| model.id == id }
      end

      def [](id)
        find(id)
      end
    end

    class List < ::Array
      include Pagination

      class << List
        def for(*args, &block)
          new(*args, &block)
        end
      end

      def select(*args, &block)
        List.for super
      end

      def detect(*args, &block)
        super
      end

      def slice(*args, &block)
        List.for super
      end
    end

    def List(*args, &block)
      List.new(*args, &block)
    end

    attr_accessor(:node)

    def initialize(*args)
      attributes = Map.options_for!(args)

      node = args.detect { |arg| arg.is_a?(Ro::Node) }
      model = args.detect { |arg| arg.is_a?(Model) }

      node = model.node if node.nil? and !model.nil?

      @node = node
    end

    def attributes
      @node.attributes
    end

    def persisted?
      true
    end

    def method_missing(method, *args, &block)
      begin
        node.send(method, *args, &block)
      rescue
        super
      end
    end

    def respond_to?(method, *args, &block)
      super || node.respond_to?(method)
    end
  end
end
