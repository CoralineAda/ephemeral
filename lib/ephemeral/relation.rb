module Ephemeral

  class Relation

    attr_accessor :object, :klass

    def initialize(klass, object=nil)
      self.klass = klass
      self.object = self.materialize(object)
      self
    end

    def materialize(object=nil)
      return nil unless object
      return object if object.class.name == self.klass
      eval(self.klass).new(object)
    end

  end

end