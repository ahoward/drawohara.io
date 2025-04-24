module Helpers
  require 'digest'

  def sample_key(key, list)
    return nil if list.empty?
    md5_hash = Digest::MD5.hexdigest(key)
    index = md5_hash.hex % list.length
    return list[index]
  end

  extend Helpers
end
