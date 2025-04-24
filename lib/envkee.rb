require 'dotenv'
require 'openssl'
require 'securerandom'

module EnvKee
  class Error; end

  def find_key!
    if ENV['KEE']
      @key = ENV['KEE']
    else
      current_dir = Dir.pwd
      while current_dir != '/'
        kee_file = File.join(current_dir, '.kee')
        if File.exist?(kee_file)
          @key = File.read(kee_file).strip
          return
        end
        current_dir = File.dirname(current_dir)
      end
      raise Error.new("key not found in environment or .kee file")
    end
  end

  def load
    find_key!

    loaded = Dotenv.load

    loaded.each do |key, value|
      if value =~ %r{^enc://}
        encrypted = value.split('//', 2).last
        decrypted = decrypt(encrypted)
        ENV[key] = decrypted
      end
    end
  end

  def key
    @key
  end

  def generate_key
    SecureRandom.hex(32)
  end

  def encrypt(string, key: EnvKee.key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = [key].pack('H*')
    encrypted = cipher.update(string) + cipher.final
    "enc://#{encrypted.unpack1('H*')}"
  end

  def decrypt(string, key: EnvKee.key)
    encrypted = [string].pack('H*')
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = [key].pack('H*')
    cipher.update(encrypted) + cipher.final
  end

  extend self
end
