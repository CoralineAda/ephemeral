require 'ephemeral'

class Rarity
  include Ephemeral::Base
  attr_accessor :name, :item_count
  scope :foos,      {:name => 'foo'}
  scope :paychecks, {:name => 'Paychecks'}
  scope :threes,    {:item_count => 3}
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class Antique
  include Ephemeral::Base
  attr_accessor :name, :item_count
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

class NotCollectible
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

    it 'defines a collection' do
      Collector.new.rarities.klass.should == Rarity
      Collector.new.antiques.klass.should == Antique
    end

    it 'accepts a class name' do
      Collector.new.junk.klass.should == NotCollectible
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

  context 'instance methods' do

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

    end

  end

end