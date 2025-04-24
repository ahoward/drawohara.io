```ruby


=begin

  it's quite common, in ruby, for modules to provide functionality via mixins.


  for example:
  

=end

  module Mixin
    def foo
      42
    end
  end

  class C
    include Mixin
  end

  p C.new.foo #=> 42

=begin

  althouge handy, the guts of the mixin, especially modules, can easily leak
  into the target unintentially.
  
  here the 'Util' module gets zippered in-between the Mixin and C:


=end

  reset!

  module Mixin
    module Util
      def Util.foo
        42
      end
    end
  end

  class C
    include Mixin

    p Util.foo #=> 42

    module Util
      def Util.bar
        42.0
      end
    end

    p Util.bar #=> 42.0
  end



=begin

  this creates a challenge for the author's of mixins: how to keep code
  organized *and* provide a module that is safe to mixin to any target.


  two main approaches exist:


  1) carve out the mixin seperately from the top-level namespace

=end

  reset!

  module M
    module Mixin
      def foo
        42
      end
    end

    module Util
    end
  end

  class C
    include M::Mixin
  end

  p C.new.foo #=> 42
  p C.const_defined?(:Util) #=> false


=begin

  or

  2) leverage const_missing to allow simple const aliases into a private namespace


=end

  reset!

  module M
    module Namespace
      module Util
        def foo
          42
        end
      end
    end

    def Mixin.const_missing(const)
      begin
        Namespace.const_get(const)
      rescue Object
        raise
      end
    end

    def foo
      Util.foo
    end
  end

  class C
    include M::Mixin
  end

  p C.new.foo #=> 42
  p C.const_defined?(:Util) #=> false 



=begin


  so, there you have it: please think carefully about dropping common names
  inside your mixins as they absolute vommit all their internals into the
  mixee.


=end









BEGIN {
  def reset!
    self.class.send :remove_const, :Mixin rescue false
    self.class.send :remove_const, :C rescue false
  end
}


```
