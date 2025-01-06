require 'map'
require_relative 'path'

class Pattern < ::Array
  attr_reader :path
  attr_reader :parts
  attr_reader :keys
  attr_reader :root
  attr_reader :regex

  def initialize(path)
    @path = Path.for(path)

    if @path == '/'
      @root = true
      @parts = []
      @keys = []
      @regex = %r`^/$`i
    else
      Pattern.compile(path) => parts:, keys:, regex:

      @root = false
      @parts = parts
      @keys = keys
      @regex = regex
    end

    @wants = []

    @path.parts.each do |part|
      case
        when part.start_with?(":")
          key = part.slice(1..).to_sym
          @wants << key.to_sym
        else
          @wants << part
      end
    end
  end

  def params_for(*args)
    params = {ext: nil}
    return params if args.empty?

    url = Path.for(*args).absolute

    raise ArgumentError.new("args=#{ args.inspect } cannot match path=#{ @path }, regex=#{ @regex.inspect }") unless @regex.match(url)

    path_info, ext = url.split('.', 2)
    values = path_info.scan(%r`[^/]+`)

    keys = @keys.dup

    @wants.each do |want|
      case want
        when Symbol
          key = want
          value = values.shift
          params[key] = value
          keys.shift
        else
          values.shift
      end
    end

    params[:ext] = ext

    params
  end

  def Pattern.compile(path)
    parts = []
    keys = []
    re = []

    autokey = 'a'

    _parts = path.to_s.strip.scan(%r`[^/]+`)

    _parts.each_with_index do |part, index|
      case
        when part.start_with?(':')
          key = part.slice(1..).to_sym
          keys.push(key)
          re.push '/'
          re.push '([^/.]+)'
          parts.push(part)

        when part == '*'
          key = autokey.to_sym
          keys.push(key)
          re.push '/'
          re.push '([^/.]+)'
          autokey.succ!
          parts.push(':%s' % key)

        when part == '**'
          key = :path_info
          keys.push(key)
          re.push '/'
          re.push '(.*)'
          parts.push(':%s' % key)

        else
          re.push '/'
          re.push('(%s)' % Regexp.escape(part))
      end
    end

    keys.push(:ext)
    re.push '([.].+)*?'

    regex = /^#{ re.join }$/i

    {parts:, keys:, regex:}
  end

  def match(path)
    @regex.match("#{ path }")
  end

  def literal?
    (@keys - [:ext]).empty?
  end

  def expand(hash = {})
    return @path if literal?

    replace = {}
    ext = hash[:ext]

    hash.each do |key, val|
      validate_key!(key)
      replace[":#{ key }"] = "#{ val }"
    end

    parts = @parts.map{|part| replace.fetch(part){ part }}

    if ext
      last = parts.pop
      last = [last, ext].join('.').gsub(%r`[.]+`, '.')
      parts.push(last)
    end

    "/#{ parts.join('/') }".squeeze('/')
  end

  def validate_key!(key)
    key = key.to_s.to_sym

    @keys.index(key) || raise(Error.new("invalid key=#{ key.inspect } for path=#{ @path.inspect }"))
  end
end
