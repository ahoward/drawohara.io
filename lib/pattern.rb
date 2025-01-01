class Pattern < ::Array
  attr_reader :path
  attr_reader :parts
  attr_reader :keys
  attr_reader :root
  attr_reader :regex

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

  def initialize(path)
    @path = "#{ path }"

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
  end

  def match(path)
    @regex.match("#{ path }")
  end

  def literal?
    @keys.empty?
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
