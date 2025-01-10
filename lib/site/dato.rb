require 'bundler/setup'

require 'yaml'
require 'json'

require 'map'

require_relative 'path'

class Dato
  ROOT = './dato'

  def Dato.load(...)
    new(...)
  end

  attr_reader :root
  attr_reader :files
  attr_reader :map

  def initialize(*args, root: nil)
    @root = Path.for(root || args.first || ROOT)
    @files = []
    @map = Map.new

    @root.glob("**/**") do |entry|
      next unless entry.file?
      file = entry
      @files.push(file)

      parts = file.relative_to(@root).parts
      parts.last.gsub!( %r`[.].*$`, '')
      key = parts

      case
        when %w[ yml yaml ].include?(file.ext)
          value = YAML.load_file(file)

        when %w[ json ].include?(file.ext)
          value = JSON.parse(IO.binread(file))

        else
          raise "invalid data file #{ file.inspect }"
      end

      @map.set(*key, value)
    end
  end

  def has?(...)
    @map.has?(...)
  end

  def set(...)
    @map.set(...)
  end

  def get(...)
    @map.get(...)
  end

  def fetch(...)
    @map.fetch(...)
  end
end
