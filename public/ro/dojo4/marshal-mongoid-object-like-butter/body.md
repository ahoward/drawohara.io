sticking your models into cache, or serializing them for other reasons shouldn't be painful.  unfortunately it is with most ORMs, as they have a lame marshal strategy by default.  however this is easy to fix: they key lies in understanding that every ORM already knows how to take a hash of info from the db and instantiate a full blown instance.  knowing this, we can easily make any model serialize like butter.


<br>

```ruby
#! /usr/bin/env ruby

# some models have whack shit that can't survive a marshal round-trip
#
  class Model
    include Mongoid::Document

    def initialize(*args, &block)
      super
    ensure
      @fail = Class.new, open(__FILE__)
    end
  end

# so this'll fail
#
  begin
    p Marshal.load(Marshal.dump(Model.create))
  rescue Object => o
    warn "#{ o.message } (#{ o.class })"
  end

# but mongoid models simply need a hash of information from the mongo driver
# to fully vivify themselves... ergo this is all we need persist when
# marshaled.  this makes loading from marshaled data *just like* loading from
# the db.
#
# if you ask me this should be the default behavior!
#
# hrm - i am on mongoid core... @durran, what do you think?
#
# btw - this works just fine with active_record too...
#
  class Model
    def _dump(*args, &block)
      Marshal.dump(raw_attributes, *args, &block)
    end

    def Model._load(string, *args, &block)
      raw_attributes = Marshal.load(string, *args, &block)
      instantiate(raw_attributes)
    end
  end

# so now it just werks (TM)
#
  p Marshal.load(Marshal.dump(Model.create))





BEGIN {
  require 'rubygems'
  require 'mongoid'

  Mongoid.configure{|config| config.connect_to('mongoid-marshal')}
}

__END__

teh outputz:

can't dump anonymous class #<Class:0x007fa89dc23768> (TypeError)

#<Model _id: 5130edd0af481ccd3d000002, >
 
```

ref: https://gist.github.com/ahoward/5066528


