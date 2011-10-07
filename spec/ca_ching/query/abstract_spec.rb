require 'spec_helper'

module CaChing
  module Query
    describe Abstract do
      describe 'SQL parsing' do
        # The queries we are concerned with take the form:
        #    SELECT [*|field1,field2,...] FROM table_name WHERE field [=|<|>|<=...] value [AND|OR] ... LIMIT x OFFSET y... ORDER BY ...
        # The tests are split up into parsing the various parts, namely:
        #  - table_name
        #  - conditions (the WHERE bit)
        #  - limit
        #  - offset
        #  - order
        # 
        # The tests conclude with parsing various complete queries to test the combination of the various parsing logics.
        describe '#order' do
          it 'returns {} if no order is set' do
            ar = Person.where(:name => 'Andrew')
            query = Abstract.new(ar)
            query.order.should == {}
          end

          it 'returns the key and desc for a singular order clause DESC' do 
            ar = Person.order('created_at DESC')
            query = Abstract.new(ar)
            query.order.should == { :created_at => :desc }
          end

          it 'returns the key and desc for a singular order clause ASC' do 
            ar = Person.order('created_at ASC')
            query = Abstract.new(ar)
            query.order.should == { :created_at => :asc }
          end

          it 'returns the keys and direction for multiple order clauses from different order calls' do 
            ar = Person.order('created_at DESC').order('name ASC')
            query = Abstract.new(ar)
            query.order.should == { :created_at => :desc, :name => :asc }
          end

          it 'returns the keys and direction for multiple order clauses from the same order call' do 
            ar = Person.order('created_at DESC, name ASC')
            query = Abstract.new(ar)
            query.order.should == { :created_at => :desc, :name => :asc }
          end

          it 'returns the keys and direction for multiple order clauses from different order calls and from the same order call' do 
            ar = Person.order('created_at DESC, name ASC').order('salary DESC')
            query = Abstract.new(ar)
            query.order.should == { :created_at => :desc, :name => :asc, :salary => :desc }
          end
        end
        
        describe '#where' do
          it 'returns {} if no where clause has been specified' do
            ar = Person.order('created_at DESC')
            query = Abstract.new(ar)
            query.where.should == {}
          end
          
          describe 'string queries' do
            it 'handles a single condition' do
              ar = Person.where('name = ?', 'Andrew')
              query = Abstract.new(ar)
              query.where.should == { :name => ['=', 'Andrew'] }
            end
            
            it 'splits on AND' do
              ar = Person.where('name = ? AND age = ?', 'Andrew', 22)
              query = Abstract.new(ar)
              query.where.should == { :name => ['=', 'Andrew'], :age => ['=', '22'] }
            end
            
            it 'handles arbitrary comparators' do
              ar = Person.where('age > ?', 18)
              query = Abstract.new(ar)
              query.where.should == { :age => ['>', '18'] }
            end
            
            it 'rejects OR conditions' do
              ar = Person.where('name = ? OR age > ?', 'Andrew', 18)
              query = Abstract.new(ar)
              lambda { query.where }.should raise_error(UncacheableConditionError)
            end
          end
          
          describe 'hash queries' do
            it 'handles a single condition' do
              ar = Person.where(:name => 'Andrew')
              query = Abstract.new(ar)
              query.where.should == { :name => ['=', 'Andrew'] }
            end
            
            it 'handles multiple clauses' do
              ar = Person.where(:name => 'Andrew', :age => 22)
              query = Abstract.new(ar)
              query.where.should == { :name => ['=', 'Andrew'], :age => ['=', 22] }
            end
          end
        end
        
        describe '#limit' do
          it 'returns the limit if one is set' do
            ar = Person.limit(10)
            query = Abstract.new(ar)
            query.limit.should == 10
          end
          
          it 'returns nil if the limit is not set' do
            ar = Person.where(:name => 'Andrew')
            query = Abstract.new(ar)
            query.limit.should == nil
          end
        end
        
        describe '#offset' do
          it 'returns the offset if one is set' do
            ar = Person.offset(10)
            query = Abstract.new(ar)
            query.offset.should == 10
          end
          
          it 'returns nil if the offset is not set' do
            ar = Person.where(:name => 'Andrew')
            query = Abstract.new(ar)
            query.offset.should == nil
          end
        end
        
        describe '#table_name' do
          it 'returns the table name' do
            ar = Person.where(:name => 'Andrew')
            query = Abstract.new(ar)
            query.table_name.should == "people"
          end
        end
        
        it 'handles complex queries' do
          ar = Person.where(:name => 'Andrew').where('age >= ? AND salary < ?', 21, 10000).order('created_at DESC').order('name DESC, age ASC').limit(20).offset(20)
          query = Abstract.new(ar)
          
          query.where.should == { :name => ['=', 'Andrew'], :age => ['>=', '21'], :salary => ['<', '10000'] }
          query.order.should == { :created_at => :desc, :name => :desc, :age => :asc }
          query.limit.should == 20
          query.offset.should == 20
        end
      end
      
      describe '#to_key' do
        it 'formats the key as table_name:field1="value1"&field2="value2"...' do
          ar = Person.where(:name => 'Andrew', :age => 22)
          query = Abstract.new(ar)
          query.to_key.should == 'people:name="Andrew"&age="22"'
        end
        
        it 'escapes quotes in a string' do
          ar = Person.where(:name => '"Howard"')
          query = Abstract.new(ar)
          query.to_key.should == 'people:name="\"Howard\""'
        end
        
        it 'separates multiple conditions by &' do
          ar = Person.where(:name => 'Andrew', :age => 22)
          query = Abstract.new(ar)
          query.to_key.should == 'people:name="Andrew"&age="22"'
        end
      end
    end
  end
end