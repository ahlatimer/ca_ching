require 'active_record'
require 'ca_ching'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

class Person < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Person', :foreign_key => 'parent_id'
  has_many :children, :class_name => 'Person', :foreign_key => 'parent_id'
  
  has_many :articles
  has_many :comments
end

class Article < ActiveRecord::Base
  belongs_to :person
  has_many :tags
  has_many :comments
  
  index :title
  index :person_id
end

class Comment < ActiveRecord::Base
  belongs_to :person
  belongs_to :article
end

class Tag < ActiveRecord::Base
  belongs_to :article
end

module Schema
  def self.create
    ActiveRecord::Base.silence do
      ActiveRecord::Migration.verbose = false

      ActiveRecord::Schema.define do
        create_table :people, :force => true do |t|
          t.integer  :parent_id
          t.string   :name
          t.integer  :salary
          t.integer  :age
          
          t.timestamps
        end

        create_table :articles, :force => true do |t|
          t.integer :person_id
          t.string  :title
          t.text    :body
          
          t.timestamps
        end

        create_table :comments, :force => true do |t|
          t.integer :article_id
          t.integer :person_id
          t.text    :body
          
          t.timestamps
        end

        create_table :tags, :force => true do |t|
          t.integer :article_id
          t.string :name
          
          t.timestamps
        end
      end
    end

    10.times do
      person = Person.make
      3.times do
        article = Article.make(:person => person)
        3.times do
          article.tags = [Tag.make, Tag.make, Tag.make]
        end
        10.times do
          Comment.make(:article => article)
        end
      end
      2.times do
        Comment.make(:person => person)
      end
    end

    Comment.make(:body => 'First post!', :article => Article.make(:title => 'Hello, world!'))

  end
end