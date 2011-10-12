require 'spec_helper'

module CaChing
  module Adapters
    describe Redis do
      before :all do
        @cache = CaChing::Adapters::Redis.new
      end
      
      before :each do
        @cache.clear!
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
        
        it 'does not return a dirty object' do
          object = [Article.where('1=1').limit(1).to_a_without_cache.first]
          ar = Article.where(:title => object.first.title)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          @cache.find(query).inject(true) { |flag, object| flag && object.changed? }.should == false
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
          object = [Article.where('1=1').to_a_without_cache.first]
          ar = Article.where(:person_id => object.first.person_id)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          
          record = ar.to_a_without_cache.first
          record.title = record.title.reverse
          
          @cache.update(record)
          @cache.find(query).first.title.should == record.title
        end
        
        describe 'key change' do
          it 'removes the object at the old key and inserts it at the new key if the key already exists' do
            articles = Article.where('1=1').to_a_without_cache
            ar = Article.where(:person_id => articles.first.person_id)
            query = CaChing::Query::Abstract.new(ar)
          
            @cache.insert(ar, :for => query)
            
            ar = Article.where(:person_id => articles.last.person_id)
            query2 = CaChing::Query::Abstract.new(ar)

            @cache.insert(ar, :for => query)
          
            record = ar.to_a_without_cache.first
            record.person_id = articles.first.person_id
            
            @cache.update(record)
          
            ar = Article.where(:person_id => 1)
            query = CaChing::Query::Abstract.new(ar)
          
            @cache.find(query).last.title.should == record.title
            @cache.find(query2).should == nil
          end
          
          it 'removes the object at the old key but does not insert it at the new if the key doesn\'t exist' do
            articles = Article.where('1=1').to_a_without_cache
            ar = Article.where(:title => articles.first.title)
            query = CaChing::Query::Abstract.new(ar)
            
            @cache.insert(ar, :for => query)
            
            record = ar.to_a_without_cache.first
            record.title = record.title.reverse

            @cache.update(record)
            @cache.find(query).should == nil
            @cache.find(CaChing::Query::Abstract.new(Article.where(:title => record.title))).should == nil
          end
        end
      end
      
      describe '#destroy' do
        it 'removes the object at the key' do
          articles = Article.where('1=1').to_a_without_cache
          ar = Article.where(:title => articles.last.title)
          query = CaChing::Query::Abstract.new(ar)
          
          @cache.insert(ar, :for => query)
          @cache.destroy(ar.first, :at => "articles:title=#{articles.last.title}")
          @cache.find(query).should == nil
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
      
      describe '#deflate' do
        
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