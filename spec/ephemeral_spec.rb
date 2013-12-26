require 'ephemeral'

class Rarity
  include Ephemeral::Base
  attr_accessor :name, :item_count
  scope :foos,      {:name => 'foo'}
  scope :paychecks, {:name => 'Paychecks'}
  scope :threes,    {:item_count => 3}
  scope :by_name,   lambda{|name| where :name => name}
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class Antique
  include Ephemeral::Base
  has_one :picker
  attr_accessor :name, :item_count
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class NotCollectible
  include Ephemeral::Base
  attr_accessor :name
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class Picker
  include Ephemeral::Base
  attr_accessor :name
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class Collector
  include Ephemeral::Base
  attr_accessor :name
  collects :rarities
  collects :antiques
  collects :junk, :class_name => 'NotCollectible'
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

describe Ephemeral do

  context 'class methods' do

    context 'collections' do

      it 'defines a collection' do
        Collector.collects[:rarities].klass.should == 'Rarity'
        Collector.collects[:antiques].klass.should == 'Antique'
      end

      it 'accepts a class name' do
        Collector.collects[:junk].klass.should == 'NotCollectible'
      end

      it 'creates a setter' do
        Collector.new.respond_to?(:rarities=).should be_true
      end

      it 'creates a getter' do
        Collector.new.respond_to?(:rarities).should be_true
      end

      it 'registers a scope' do
        Rarity.scopes.include?(:foos).should be_true
      end

    end

    context 'relations' do

      it 'defines a relation' do
        Antique.new(:picker => {:name => 'Frank Fritz'}).picker.is_a?(Picker).should be_true
      end

    end
  end

  context 'instance methods' do

    context 'relations' do

      it 'initializes with a hash' do
        antique = Antique.new(:name => 'Model T Ford', :item_count => 1, :picker => {:name => "Mike Wolfe"} )
        antique.picker.name.should == "Mike Wolfe"
      end

      it 'initializes with a materialized object' do
        picker = Picker.new(:name => 'Mike Wolfe')
        antique = Antique.new(:name => 'Model T Ford', :item_count => 1, :picker => picker )
        antique.picker.name.should == "Mike Wolfe"
      end

    end

    context 'collections' do

      before :each do

        @rarities = [
          Rarity.new(:name => 'Paychecks', :item_count => 1),
          Rarity.new(:name => 'Paychecks', :item_count => 3),
          Rarity.new(:name => 'Requisitions', :item_count => 2),
        ]

        @antiques = [
          Antique.new(:name => 'Trading Cards', :item_count => 100)
        ]

        @collector = Collector.new(:name => 'Hermes')
        @collector.rarities = @rarities
        @collector.antiques = @antiques

      end

      describe 'initializes with materialized objects' do

        it 'from a setter' do
          collector = Collector.new(
            :name => 'from_api',
            'rarities' => [
              {'name' => 'foo'},
              {'name' => 'bar'}
            ]
          )
          collector.rarities.count.should == 2
        end

      end

      it 'performs a where' do
        @collector.rarities.where(:name => 'Paychecks').should_not be_blank
        @collector.antiques.where(:name => 'Trading Cards').should_not be_blank
      end

      describe 'scope method' do

        it 'executes a scope' do
          @collector.rarities.paychecks.first.should_not be_nil
        end

        it 'returns a collection' do
          @collector.rarities.paychecks.class.name.should == 'Ephemeral::Collection'
        end

        it 'chains scopes' do
          @collector.rarities.paychecks.threes.count.should == 1
        end

        it 'handle lambda scopes' do
          @collector.rarities.by_name('Paychecks').count.should == 2
        end

      end

    end

  end

end