require 'spec_helper'

module CaChing
  module Adapters
    describe Arel do
      describe '#parse_where_values' do
        it 'returns {} if no where values are set' do
          Arel.process_where_values(Person.order('created_at DESC').where_values).should == {}
        end
        
        it 'fails' do
          true.should == false
        end
      end
      
      describe '#parse_order_values' do
        it 'returns {} if no order is set' do
          Arel.process_order_values(Person.where('id != ?', nil).order_values).should == {}
        end
        
        it 'returns the key and desc for a singular order clause DESC' do 
          Arel.process_order_values(Person.order('created_at DESC').order_values).should == { :created_at => :desc }
        end
        
        it 'returns the key and desc for a singular order clause ASC' do 
          Arel.process_order_values(Person.order('created_at ASC').order_values).should == { :created_at => :asc }
        end
        
        it 'returns the keys and direction for multiple order clauses from different order calls' do 
          Arel.process_order_values(Person.order('created_at DESC').order('name ASC').order_values).should == { :created_at => :desc, :name => :asc }
        end
        
        it 'returns the keys and direction for multiple order clauses from the same order call' do 
          Arel.process_order_values(Person.order('created_at DESC, name ASC').order_values).should == { :created_at => :desc, :name => :asc }
        end
        
        it 'returns the keys and direction for multiple order clauses from different order calls and from the same order call' do 
          Arel.process_order_values(Person.order('created_at DESC, name ASC').order('salary DESC').order_values).should == { :created_at => :desc, :name => :asc, :salary => :desc }
        end
      end
      
      describe '#parse_limit_values' do
        it 'returns the limit if one is set' do
          Arel.process_limit_values(Person.limit(1000).limit_value).should == 1000
        end
        
        it 'returns nil if no limit is set' do
          Arel.process_limit_values(Person.where('id != ?', nil).limit_value).should == nil          
        end
      end
    end
  end
end