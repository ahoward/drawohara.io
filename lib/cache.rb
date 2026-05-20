require 'map'

#
# Cache < Map — explicit, transactional memoization layer.
#
# usage:
#   cache = Cache.new
#   urls = cache.get(:site, :urls){ site.urls }     # computes and stores
#   urls = cache.get(:site, :urls){ site.urls }     # returns cached value
#
# keys are nested by position (compound keys via varargs). lookups and writes
# are thread-safe: the block runs at most once per key tuple even under
# concurrent access from multiple threads.
#
class Cache < Map
  def initialize(*args, **kws, &block)
    super
    @lock = Monitor.new
    @keylocks = {}
  end

  # transactional fetch: returns the cached value at `keys`, computing and
  # storing it via the block on first miss. concurrent callers wait on the
  # same key; the block runs once.
  def get(*keys, &block)
    raise ArgumentError, 'Cache#get requires at least one key' if keys.empty?

    # quick read path — no per-key lock if already present
    found = read(keys)
    return found.first if found.size == 1

    # acquire (or create) a per-key monitor so concurrent misses serialize
    keylock = @lock.synchronize do
      @keylocks[keys] ||= Monitor.new
    end

    keylock.synchronize do
      found = read(keys)
      return found.first if found.size == 1

      raise ArgumentError, "Cache#get(#{ keys.inspect }) called without a block" unless block

      value = block.call
      write(keys, value)
      value
    end
  end

  def set(*keys, value)
    @lock.synchronize do
      write(keys, value)
    end
    value
  end

  def cached?(*keys)
    !read(keys).empty?
  end

  def clear!
    @lock.synchronize do
      clear
      @keylocks.clear
    end
  end

  protected

  # nested traversal: `read([:a, :b])` returns `[self[:a][:b]]` if present,
  # `[]` if missing at any level. wrapping in an array distinguishes
  # "present with nil value" from "absent".
  def read(keys)
    @lock.synchronize do
      node = self
      keys.each do |k|
        return [] unless node.is_a?(Hash) && node.key?(k)
        node = node[k]
      end
      [node]
    end
  end

  def write(keys, value)
    node = self
    keys[0..-2].each do |k|
      node[k] = Map.new unless node[k].is_a?(Hash)
      node = node[k]
    end
    node[keys.last] = value
  end
end
