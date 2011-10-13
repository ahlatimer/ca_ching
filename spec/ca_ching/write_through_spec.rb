require 'spec_helper'

module CaChing
  describe WriteThrough do
    before :all do
      @person = Person.where(:id => 1).to_a_without_cache.first
      @cache = CaChing::Adapters::Redis.new
    end
    
    before :each do
      @cache.clear!
    end
    
    it 'updates the cache for a cached object' do
      ar = Person.where(:id => 1)
      query = CaChing::Query::Abstract.new(ar)
      @cache.insert(ar.to_a_without_cache, :for => query)
      
      @person.name = @person.name.reverse
      @person.save
      
      @cache.find(CaChing::Query::Abstract.new(ar)).first.name.should == @person.name
    end
  end
end