class DSL < ::BasicObject
  def self.call(_self, &block)
    dsl =
      allocate

    ::Object.instance_method(:instance_variable_set).
      bind(dsl).
      call(:@_self, _self)

    ::Object.instance_method(:instance_exec).
      bind(dsl).
      call(&block)
  end

  attr_reader :_self

  def self.const_missing(const)
    ::Kernel.const_get(const)
  end
end
