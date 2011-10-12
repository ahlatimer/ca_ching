require 'spec_helper'

module CaChing
  module Adapters
    describe Redis do
      before :all do
        @cache = CaChing::Adapters::Redis.new
      end
      
      describe '#find' do
        it 'finds the object(s) for the given query' do
          object = [Article.where('1=1').limit(1).to_a_without_cache.first]
          ar = Article.where(:title => object.first.title)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          @cache.find(query).should == object
        end
        
        it 'returns nil if the objects are not found' do
          ar = Article.where(:title => 'Foo bar')
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.find(query).should == nil
        end
      end
      
      describe '#insert' do
        it 'inserts the objects for a query with one where clause' do
          object = [Article.where('1=1').limit(1).to_a_without_cache.first]
          ar = Article.where(:title => object.first.title)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          @cache.find(query).should == object
        end
        
        it 'does not insert the objects for a query with multiple where clauses' do
          ar = Article.where(:person_id => 1, :title => 'Foo bar')
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          @cache.find(query).should == nil
        end
        
        it 'returns nil if the operation was unsuccessful' do
          ar = Article.where(:person_id => 1, :title => 'Foo bar')
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query).should == nil
        end
        
        it 'returns the objects inserted if the operation was successful' do
          object = [Article.where('1=1').to_a_without_cache.first]
          ar = Article.where(:title => object.first.title)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query).should == object
        end
      end
      
      describe '#update' do        
        it 'updates the object at the given key' do
          true.should == false
        end
      end
      
      describe '#destroy' do
        it 'removes the object at the key' do
          
        end
      end
      
      describe '#destroy_all' do
        it 'removes all of the objects at the key' do
          
        end
      end
      
      describe '#clear!' do
        it 'clears redis' do
          
        end
      end
      
      describe '#inflate' do
        it 'turns the stored objects back into AR objects' do
          
        end
      end
      
      describe '#deflate_with_score' do
        it 'turns the objects into JSON strings' do
          
        end
        
        it 'uses the score method if provided' do
          
        end
        
        it 'defaults to using id if no score method is provided' do
          
        end
      end
    end
  end

end