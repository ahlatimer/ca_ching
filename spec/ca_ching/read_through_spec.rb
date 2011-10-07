require 'spec_helper'

module CaChing
  describe ReadThrough do
    describe 'finding on indexed fields' do
      describe 'cache hit' do
        before(:all) do
          # Get some examples without hitting the cache
          @person = Person.where(:id => 1).to_a_without_cache.first
          # And prime the cache
          # ...
        end
        
        it 'returns the result without querying the database' do
          person = Person.find(1)
          @person.attributes.should == person.attributes
        end
        
        it 'finds by id' do
          person = Person.find(1)
          @person.attributes.should == person.attributes
        end
        
        describe 'dynamic finders' do
          it 'finds with one parameter' do
            person = Person.find_by_name(@person.name)
            @person.attributes.should == person.attributes
          end
          
          it 'finds with many parameters' do
            pending
          end
          
          it 'finds all with one parameter' do
            pending
          end
          
          it 'finds all with many parameters' do
            pending
          end
        end
        
        describe 'Arel-style finders' do
          describe 'where' do
            it 'finds with one parameter' do
              pending
            end
            
            it 'finds with many parameters' do
              pending
            end
          end
          
          describe 'order' do
            it 'finds if the order matches the order on an indexed field in the query' do
              pending
            end
            
            it 'skips the cache if the order does not match an order on an indexed field in the query' do
              pending
            end
          end
        end
      end
      
      describe 'cache miss' do
        it 'stores the result returned from the database' do
          pending
        end
        
        it 'finds by id' do
          pending
        end
        
        describe 'dynamic finders' do
          it 'finds with one parameter' do
            pending
          end
          
          it 'finds with many parameters' do
            pending
          end
          
          it 'finds all with one parameter' do
            pending
          end
          
          it 'finds all with many parameters' do
            pending
          end
        end
        
        describe 'Arel-style finders' do
          describe 'where' do
            it 'finds with one parameter' do
              pending
            end
            
            it 'finds with many parameters' do
              pending
            end
          end
          
          describe 'order' do
            it 'finds if the order matches the order on an indexed field in the query' do
              pending
            end
            
            it 'skips the cache if the order does not match an order on an indexed field in the query' do
              pending
            end
          end
          
          describe 'limit' do
            it 'limits the returned set to the number specified in limit' do
              pending
            end
          end
          
          describe 'join, include, etc.' do
            it 'skips the cache' do
              pending
            end
          end
        end
      end
      
    end
    
    describe 'finding on non-indexed fields' do
      it 'does not attempt to find via the cache' do
        pending
      end
    end    
  end
end