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
          person.from_cache?.should == true
          person.should == Person.where(:id => 1).to_a_without_cache.first
        end
        
        it 'finds by id' do
          person = Person.find(1)
          person.from_cache?.should == true
          person.should == Person.where(:id => 1).to_a_without_cache.first
        end
        
        describe 'dynamic finders' do
          it 'finds with one parameter' do
            person = Person.find_by_name(@person.name)
            person.from_cache?.should == true
            person.should == @person
          end
          
          it 'finds with many parameters' do
            person = Person.find_by_name_and_age(@person.name, @person.age)
            person.from_cache?.should == true
            person.should == @person
          end
          
          it 'finds all with one parameter' do
            people = Person.find_all_by_age(@person.age)
            people.from_cache?.should == true
            people.map { |p| p.id }.sort.should == Person.where(:age => @person.age).to_a_without_cache.map { |p| p.id }.sort
          end
          
          it 'finds all with many parameters' do
            people = Person.find_all_by_age_and_salary(@person.age, @person.salary)
            people.from_cache?.should == true
            people.map { |p| p.id }.sort.should == Person.where(:age => @person.age, :salary => @person.salary).to_a_without_cache.map { |p| p.id }.sort
          end
        end
        
        describe 'Arel-style finders' do
          describe 'where' do
            it 'finds with one parameter' do
              people = Person.where(:age => @person.age).all
              people.from_cache?.should == true
              people.should == Person.where(:age => @person.age).to_a_without_cache
            end
            
            it 'finds with many parameters' do
              people = Person.where(:age => @person.age, :salary => @person.salary).all
              people.from_cache?.should == true
              people.should == Person.where(:age => @person.age, :salary => @person.salary).to_a_without_cache
            end
          end
          
          describe 'order' do
            it 'finds if the order matches the order on an indexed field in the query' do
              people = Person.where(:salary => @person.salary).order('salary DESC').all
              people.from_cache?.should == true
              people.should == Person.where(:salary => @person.salary).order('salary DESC').to_a_without_cache
            end
            
            it 'skips the cache if the order does not match an order on an indexed field in the query' do
              people = Person.where(:salary => @person.salary).order('salary ASC').all
              people.from_cache?.should == false
            end
          end
        end
      end
      
      describe 'cache miss' do
        before :each do
          CaChing.cache.clear!
        end
        
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