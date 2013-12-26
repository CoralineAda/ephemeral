module Ephemeral

  module Base

    require 'active_support/core_ext/object/blank'
    require 'active_support/core_ext/string/inflections'

    def self.included(base)
      base.extend ClassMethods
      base.send(:attr_accessor, :relations)
      base.send(:attr_writer, :collections)
    end

    def collections
      @collections ||= {}
    end

    module ClassMethods

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
        @@scopes ||= {}
      end

    end

  end

end