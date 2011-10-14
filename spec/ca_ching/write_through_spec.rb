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
    
    it 'updates the cache for a cached object with AR#save' do
      ar = Person.where(:id => 1)
      query = CaChing::Query::Abstract.new(ar)
      @cache.insert(ar.to_a_without_cache, :for => query)
      
      name = @person.name.reverse
      
      @person.name = name
      @person.save
      
      @cache.find(CaChing::Query::Abstract.new(ar)).first.name.should == name
    end

    it 'updates the cache for a cached object with AR#save!' do
      ar = Person.where(:id => 1)
      query = CaChing::Query::Abstract.new(ar)
      @cache.insert(ar.to_a_without_cache, :for => query)
      
      name = @person.name.reverse
      
      @person.name = name
      @person.save!
      
      @cache.find(CaChing::Query::Abstract.new(ar)).first.name.should == name
    end
    
    it 'updates the cache for a cached object with AR#update_attributes' do
      ar = Person.where(:id => 1)
      query = CaChing::Query::Abstract.new(ar)
      @cache.insert(ar.to_a_without_cache, :for => query)

      name = @person.name.reverse
      @person.update_attributes(:name => name)
      
      @cache.find(CaChing::Query::Abstract.new(ar)).first.name.should == name
    end
  end
end