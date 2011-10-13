require 'spec_helper'

module CaChing
  describe ReadThrough do
    describe 'finding on indexed fields' do
      before :all do
        @person = Person.where(:id => 1).to_a_without_cache.first
        @cache = CaChing::Adapters::Redis.new
      end
      
      before :each do
        @cache.clear!
      end
      
      describe 'cache hit' do
        before(:each) do
          # Prime the cache
          @cache.insert(Person.where(:id => 1).to_a_without_cache, :for => CaChing::Query::Abstract.new(Person.where(:id => 1)))
          @cache.insert(Person.where(:name => @person.name).to_a_without_cache, :for => CaChing::Query::Abstract.new(Person.where(:name => @person.name)))
          @cache.insert(Person.where(:age => @person.age).to_a_without_cache, :for => CaChing::Query::Abstract.new(Person.where(:age => @person.age)))
          @cache.insert(Person.where(:age => @person.age, :salary => @person.salary).to_a_without_cache, :for => CaChing::Query::Abstract.new(Person.where(:age => @person.age, :salary => @person.salary)))
          @cache.insert(Article.where(:person_id => @person.id).to_a_without_cache, :for => CaChing::Query::Abstract.new(Article.where(:person_id => @person.id)))
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
            pending
            
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
            pending
            
            people = Person.find_all_by_age_and_salary(@person.age, @person.salary)
            people.from_cache?.should == true
            people.should == Person.where(:age => @person.age, :salary => @person.salary).to_a_without_cache
          end
        end
        
        describe 'Arel-style finders' do
          describe 'where' do
            it 'finds with one parameter' do
              people = Person.where(:age => @person.age).all
              people.from_cache?.should == true
              people.sort.should == Person.where(:age => @person.age).to_a_without_cache.sort
            end
            
            it 'finds with many parameters' do
              pending
              
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
          
          describe 'limit' do
            it 'limits the returned set to the number specified in limit' do
              articles = Article.where(:person_id => @person.id).limit(2).all
              articles.size.should == 2
              articles.from_cache?.should == true
            end
          end
          
          describe 'offset' do
            it 'offsets the returned set by the number specified' do
              articles = Article.where(:person_id => @person.id).offset(3).all
              articles.from_cache?.should == true
              Article.where(:person_id => @person.id).offset(3).to_a_without_cache.should == articles
            end
          end
          
          describe 'join, include, etc.' do
            it 'skips the cache' do
              Article.where(:person_id => @person.id).includes(:person).all.from_cache?.should == false
            end
          end
        end
      end
      
      describe 'cache miss' do
        it 'stores the result returned from the database' do
          person = Person.find(1)
          person.from_cache?.should == false
          
          person = Person.find(1)
          person.from_cache?.should == true
        end
        
        it 'finds by id' do
          person = Person.find(1)
          person.from_cache?.should == false
          
          person = Person.find(1)
          person.from_cache?.should == true
        end
        
        describe 'dynamic finders' do
          it 'finds with one parameter' do
            person = Person.find_by_name(@person.name)
            person.from_cache?.should == false
            
            person = Person.find_by_name(@person.name)
            person.from_cache?.should == true
          end
          
          it 'finds with many parameters' do
            pending
            
            person = Person.find_by_name_and_age(@person.name, @person.age)
            person.from_cache?.should == false
            
            person = Person.find_by_name_and_age(@person.name, @person.age)
            person.from_cache?.should == true
          end
          
          it 'finds all with one parameter' do
            person = Person.find_all_by_name(@person.name)
            person.from_cache?.should == false
            
            person = Person.find_all_by_name(@person.name)
            person.from_cache?.should == true
          end
          
          it 'finds all with many parameters' do
            pending
            
            person = Person.find_all_by_name_and_age(@person.name, @person.age)
            person.from_cache?.should == false
            
            person = Person.find_all_by_name_and_age(@person.name, @person.age)
            person.from_cache?.should == true
          end
        end
        
        describe 'Arel-style finders' do
          describe 'where' do
            it 'finds with one parameter' do
              person = Person.where(:name => @person.name).all
              person.from_cache?.should == false
              
              person = Person.where(:name => @person.name).all
              person.from_cache?.should == true
            end
            
            it 'finds with many parameters' do
              pending
              person = Person.where(:name => @person.name, :age => @person.age).all
              person.from_cache?.should == false
              
              person = Person.where(:name => @person.name, :age => @person.age).all
              person.from_cache?.should == true
            end
          end
          
          describe 'limit' do
            it 'will cache an incorrect number of items' do
              true.should == false
            end
          end
        end
      end
      
    end
    
    describe 'finding on non-indexed fields' do
      it 'does not attempt to find via the cache' do
        Tag.where(:name => 'abc').all.from_cache?.should == false
        # Do it twice to illustrate that it isn't cached on miss (because there is no miss)
        Tag.where(:name => 'abc').all.from_cache?.should == false
      end
    end    
  end
end