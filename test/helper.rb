require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'shoulda/active_record'
require 'factory_girl'

gem 'sqlite3-ruby'

require 'active_record'
require 'active_support'

require 'lib/has_many_friends'

# Connect to database
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.establish_connection(config['test'])

# Create tables
ActiveRecord::Base.connection.create_table(:users, :force => true) do |table|
	table.column :name, :string
	table.column :status, :string
	table.column :updated_at, :datetime
end

ActiveRecord::Base.connection.create_table(:relationships, :force => true) do |table|
	table.column :type, :string
	table.column :user_id, :integer
	table.column :friend_id, :integer
	table.column :rival_id, :integer
	table.column :created_at, :datetime
	table.column :accepted_at, :datetime
end

# Dummy classes
class User < ActiveRecord::Base; include HasManyFriends::Models::User; end
class Relationship < ActiveRecord::Base; include HasManyFriends::Models::Relationship; end
class Friendship < Relationship; include HasManyFriends::Models::Friendship; end
class Rivalry < Relationship; include HasManyFriends::Models::Rivalry; end
