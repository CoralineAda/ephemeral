module Ephemeral

  class Relation

    attr_accessor :object, :klass

    def initialize(klass, object=nil)
      self.klass = eval(klass)
      self.object = self.materialize(object)
      self
    end

    def materialize(object=nil)
      return nil unless object
      return object if object.is_a? self.klass
      self.klass.new(object)
    end

  end

end