module Ephemeral

  class Collection

    include Enumerable

    attr_accessor :objects, :klass

    def self.respond_to?(method_sym, include_private = false)
      if Collection.new(method_sym).match? || Collection.new.eval(klass).scopes[method_name]
        true
      end
    end

    def initialize(klass, objects=[])
      self.klass = klass
      attach_scopes
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
      results = args.inject([]) {|a, (k, v)| a << self.objects.select {|o| o.send(k) == v} }
      results = results.flatten.select {|r| results.flatten.count(r) == results.count }.uniq
      Ephemeral::Collection.new(self.klass, results)
    end

    def last
      self.objects.last
    end

    def materialize(objects_array=[])
      return [] unless objects_array
      return objects_array if objects_array && objects_array.first.class.name == self.klass
      objects_array.map{|t| eval(self.klass).new(t) }
    end

    def execute_scope(method=nil)
      #return Ephemeral::Collection.new(self.klass.name) unless self.objects
      results = eval(self.klass).scopes[method].inject([]) {|a, (k, v)| a << self.objects.select {|o| o.send(k) == v } }
      results = results.flatten.select {|r| results.flatten.count(r) == results.count }.uniq
      Ephemeral::Collection.new(self.klass, results)
    end

    def << (objekts)
      self.objects << objekts
      self.objects.flatten!
    end

    def marshal_dump
      [@klass, @objects]
    end

    def marshal_load(array=[])
      @klass, @objects = array
      attach_scopes
    end

    def attach_scopes
      eval(self.klass).scopes.each do |k, v|
        if v.is_a?(Proc)
          define_singleton_method(k, v) 
        else
          define_singleton_method k, lambda { self.execute_scope(k)}
        end
      end
    end

    def method_missing(method_name, *arguments, &block)
      scope = eval(self.klass).scopes[method_name]
      super if scope.nil?
      if scope.is_a?(Proc)
        scope.call(arguments)
      else
        execute_scope(method_name)
      end
    end

  end

end