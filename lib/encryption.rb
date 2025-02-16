require 'openssl'
require 'base64'

module AsymmetricEncryption

  def self.encrypt(plaintext)
    public_key = OpenSSL::PKey::RSA.new(ENV['PUBLIC_KEY'])
    ciphertext = public_key.public_encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  rescue OpenSSL::PKey::RSAError => e
    puts "Encryption error: #{e.message}"
    nil
  rescue ArgumentError => e
    puts "Public key or plaintext error: #{e.message}"
    nil
  end

  def self.decrypt(ciphertext_base64)
    private_key = OpenSSL::PKey::RSA.new(ENV['PRIVATE_KEY'])
    ciphertext = Base64.strict_decode64(ciphertext_base64)
    plaintext = private_key.private_decrypt(ciphertext)
    plaintext
  rescue OpenSSL::PKey::RSAError => e
    puts "Decryption error: #{e.message}"
    nil
  rescue ArgumentError => e
    puts "Private key or ciphertext error: #{e.message}"
    nil
  end

  def self.generate_keypair(key_length = 2048) # Optional key length, defaults to 2048
    keypair = OpenSSL::PKey::RSA.generate(key_length)
    {
      public_key: keypair.public_key.to_s,
      private_key: keypair.to_s
    }
  rescue OpenSSL::PKey::RSAError => e
    puts "Key generation error: #{e.message}"
    nil
  end
end

# Example Usage (after setting ENV variables!):
# Important: Generate keys and set environment variables before running encryption/decryption!

# Example Key Generation (only do this once, and store the keys securely!):
keys = AsymmetricEncryption.generate_keypair()
puts "Public Key:\n#{keys[:public_key]}"
puts "Private Key:\n#{keys[:private_key]}"
ENV['PUBLIC_KEY'] = keys[:public_key]
ENV['PRIVATE_KEY'] = keys[:private_key]

# Example encryption/decryption
plaintext = "This is a secret message."
encrypted_message = AsymmetricEncryption.encrypt(plaintext)

if encrypted_message
  puts "Encrypted: #{encrypted_message}"
  decrypted_message = AsymmetricEncryption.decrypt(encrypted_message)
  if decrypted_message
    puts "Decrypted: #{decrypted_message}"
  end
end
