module Ephemeral

  module Base

    require 'active_support/core_ext/object/blank'
    require 'active_support/core_ext/string/inflections'

    def self.included(base)
      base.extend ClassMethods
      base.send(:attr_accessor, :relations)
      base.send(:attr_writer, :collections)
      base.send(:class_variable_set, "@@objects", [])
    end

    def collections
      @collections ||= {}
    end

    module ClassMethods

      def new(*args, &block)
        object = allocate
        object.send(:initialize, *args, &block)
        objects = class_variable_get("@@objects")
        class_variable_set("@@objects", [objects, object].flatten)
        object
      end

      def collects(name=nil, args={})
        return @@collections unless name
        class_name = args[:class_name] || name.to_s.classify
        @@collections ||= {}
        @@collections[name] = Ephemeral::Collection.new(class_name)

        self.send :define_method, name do
          self.collections[class_name] ||= Ephemeral::Collection.new(class_name)
          self.collections[class_name]#.objects
        end

        self.send :define_method, "#{name}=" do |objects|
          self.collections[class_name] = Ephemeral::Collection.new(class_name, objects)
        end

      end

      def has_one(name, args={})
        class_name = args[:class_name] || name.to_s.classify
        self.send :define_method, name do
          self.relations ||= {}
          self.relations[class_name] ||= Ephemeral::Relation.new(class_name).materialize
        end
        self.send :define_method, "#{name}=" do |object|
          self.relations ||= {}
          self.relations[class_name] = Ephemeral::Relation.new(class_name).materialize(object)
        end
      end

      def scope(name, conditions)
        self.scopes ||= {}
        self.scopes[name] = conditions
      end

      def scopes
        begin
          return @@scopes if @@scopes
        rescue
          @@scopes = {}
          attach_scopes
        ensure
          return @@scopes
        end
      end

      def collections
        @@collections ||= {}
      end

      def objects
        class_variable_get("@@objects")
      end

      def attach_scopes
        scopes.each do |k, v|
          if v.is_a?(Proc)
            define_singleton_method(k, v)
          else
            define_singleton_method k, lambda { self.execute_scope(k)}
          end
        end
      end

      def method_missing(method_name, *arguments, &block)
        scope = scopes[method_name]
        super if scope.nil?
        if scope.is_a?(Proc)
          scope.call(arguments)
        else
          execute_scope(method_name)
        end
      end

      def execute_scope(method=nil)
        results = scopes[method].inject([]) {|a, (k, v)| a << self.objects.select {|o| o.send(k) == v } }.flatten
        Ephemeral::Collection.new(self.name, results)
      end

    end

  end

end