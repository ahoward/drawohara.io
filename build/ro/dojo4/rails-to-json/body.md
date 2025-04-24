rails, including rails3, has this lovely bit of code related to providing a "to_json" method on built-ins:

```ruby

# Hack to load json gem first so we can overwrite its to_json.
    begin
      require 'json'
    rescue LoadError
    end

    # The JSON gem adds a few modules to Ruby core classes containing :to_json definition, overwriting
    # their default behavior. That said, we need to define the basic to_json method in all of them,
    # otherwise they will always use to_json gem implementation, which is backwards incompatible in
    # several cases (for instance, the JSON implementation for Hash does not work) with inheritance
    # and consequently classes as ActiveSupport::OrderedHash cannot be serialized to json.
    [Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
      klass.class_eval <<-RUBY, __FILE__, __LINE__
# Dumps object in JSON (JavaScript Object Notation). See www.json.org for more info.
def to_json(options = nil)
ActiveSupport::JSON.encode(self, options)
end
RUBY
    end

```

what this effectively does is clobber the "to_json" method the json gem provides with one that active_support feels is better. the comment about json being broken is out of date and this was hack to begin with. in my case i really like this sort of thing in my /api controller:

```ruby

  def to_json(object)
    if Rails.env.production?
      JSON.generate(object)
    else
      JSON.pretty_generate(object)
    end
  end

```

since it makes debugging a shit-ton easier. here's how i did it in a rails3 app -

step one was to make rails3 support the "preinitializer" concept that old-skool rails used to have:

```ruby

    ### file: config/preinitializer.rb

    dirname = File.dirname(File.expand_path(__FILE__))
    glob = File.join(dirname, 'preinitializers', '**/**.rb')
    preinitializers = Dir.glob(glob)

    preinitializers.each{|preinitializer| Kernel.load(preinitializer)}

```

next, i added this preinitializer:

```ruby

### file: config/preinitializers/un_fuck_to_json.rb

    begin
      require 'rubygems'
    rescue LoadError
    end

    begin
      require 'json'
    rescue LoadError
    end

    [Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
      klass.class_eval do
        alias_method('__to_json__', 'to_json') if method_defined?('to_json')
      end
    end

```

finally, this initializer:

```ruby

### file: config/preinitializers/un_fuck_to_json.rb

    begin
      require 'rubygems'
    rescue LoadError
    end

    begin
      require 'json'
    rescue LoadError
    end

    [Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
      klass.class_eval do
        alias_method('__to_json__', 'to_json') if method_defined?('to_json')
      end
    end

```

in english what this does is

- make rails support code that runs before all else
- during this phase suck in the json gem and remember how it does things
- nuke the rails' way and restore the json method of to_json

