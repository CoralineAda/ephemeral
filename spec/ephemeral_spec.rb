require 'ephemeral'

class Collectible
  include Ephemeral::Base
  attr_accessor :name, :item_count
  scope :foos,      {:name => 'foo'}
  scope :paychecks, {:name => 'Paychecks'}
  scope :threes,    {:item_count => 3}
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
  collects :collectibles
  collects :junk, :class_name => 'NotCollectible'
  def initialize(args={}); args.each{|k,v| self.send("#{k}=", v)}; end
end

describe Ephemeral do

  context 'class methods' do

    it 'defines a collection' do
      Collector.new.collectibles.klass.should == Collectible
    end

    it 'accepts a class name' do
      Collector.new.junk.klass.should == NotCollectible
    end

    it 'creates a setter' do
      Collector.new.respond_to?(:collectibles=).should be_true
    end

    it 'creates a getter' do
      Collector.new.respond_to?(:collectibles).should be_true
    end

    it 'registers a scope' do
      Collectible.scopes.include?(:foos).should be_true
    end

  end

  context 'instance methods' do

    before :each do

      @collectibles = [
        Collectible.new(:name => 'Paychecks', :item_count => 1),
        Collectible.new(:name => 'Paychecks', :item_count => 3),
        Collectible.new(:name => 'Requisitions', :item_count => 2),
      ]

      @collector = Collector.new(:name => 'Hermes')
      @collector.collectibles = @collectibles

    end

    describe 'initializes with materialized objects' do

      it 'from a setter' do
        collector = Collector.new(
          :name => 'from_api',
          'collectibles' => [
            {'name' => 'foo'},
            {'name' => 'bar'}
          ]
        )
        collector.collectibles.count.should == 2
      end

    end

    it 'performs a where' do
      @collector.collectibles.where(:name => 'Paychecks').should_not be_blank
    end

    describe 'scope method' do

      it 'executes a scope' do
        @collector.collectibles.paychecks.first.should_not be_nil
      end

      it 'returns a collection' do
        @collector.collectibles.paychecks.class.name.should == 'Ephemeral::Collection'
      end

      it 'chains scopes' do
        @collector.collectibles.paychecks.threes.count.should == 1
      end

    end

  end

end