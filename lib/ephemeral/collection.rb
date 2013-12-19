module Ephemeral

  class Collection

    include Enumerable

    attr_accessor :objects, :klass

    def initialize(klass, objects=[])
      self.klass = eval(klass)
      self.klass.scopes.each do |k, v|
        if v.is_a?(Proc)
          define_singleton_method(k, v) 
        else
          define_singleton_method k, lambda { self.execute_scope(k)}
        end
      end
      self.objects = self.materialize(objects)
      self
    end

    def each(&block)
      self.objects && self.objects.each(&block)
    end

    def empty?
      self.objects.empty?
    end

    def where(args={})
      return [] unless self.objects
      results = args.inject([]) {|a, (k, v)| a << self.objects.select {|o| o.send(k) == v} }
      results = results.flatten.select {|r| results.flatten.count(r) == results.count }.uniq
      Ephemeral::Collection.new(self.klass.name, results)
    end

    def last
      self.objects.last
    end

    def materialize(objects_array=[])
      return [] unless objects_array
      return objects_array if objects_array && objects_array.first.class == self.klass
      objects_array.map{|t| self.klass.new(t) }
    end

    def execute_scope(method=nil)
      return Ephemeral::Collection.new(self.klass.name) unless self.objects
      results = self.klass.scopes[method].inject([]) {|a, (k, v)| a << self.objects.select {|o| o.send(k) == v } }
      results = results.flatten.select {|r| results.flatten.count(r) == results.count }.uniq
      Ephemeral::Collection.new(self.klass.name, results)
    end

    def << (objekts)
      self.objects += objekts
    end

  end

end