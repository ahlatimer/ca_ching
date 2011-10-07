require 'spec_helper'

module CaChing
  describe Index do
    it 'allows indexes to be defined' do
      Person.index :name
      Person.indexes?(:name).should == true
    end
    
    describe Index, 'index options' do
      it 'allows indexes to be defined with options' do
        Person.index :name, :order => { :age => :asc }, :ttl => 12.seconds
        Person.indexes?(:name).should == true
        Person.send(:indexed_fields)[:name].should == { :order => { :age => :asc }, :ttl => 12.seconds }
      end
      
      it 'rejects unsupported options' do
        lambda { Person.index :name, :not => :valid }.should raise_error(InvalidOptionError)
      end
    end
  end
end