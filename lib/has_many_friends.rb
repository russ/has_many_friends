module HasManyFriends
  module Models
		module Relationship
			def self.included(model)
			end
		end

		module Friendship
			def self.included(model)
				model.class_eval do
  				belongs_to :friendshipped_by_me, :foreign_key => 'user_id', :class_name => 'User'
  				belongs_to :friendshipped_for_me, :foreign_key => 'friend_id', :class_name => 'User'
				end
			end
		end

		module Rivalry
			def self.included(model)
				model.class_eval do
					belongs_to :rivaled_by_me, :foreign_key => 'user_id', :class_name => 'User'
					belongs_to :rivaled_for_me, :foreign_key => 'rival_id', :class_name => 'User'
				end
			end
		end

		module User
			def self.included(model)
				model.send(:include, InstanceMethods)
				model.class_eval do
					has_many :friendships_by_me, :foreign_key => 'user_id', :class_name => 'Friendship'
					has_many :friendships_for_me, :foreign_key => 'friend_id', :class_name => 'Friendship'

					has_many :friends_by_me,
									 :through => :friendships_by_me,
									 :source => :friendshipped_for_me,
									 :conditions => 'accepted_at IS NOT NULL' do
									   def online
                       find(:all, :conditions => [ 'status <> ? AND updated_at > ?', 'offline', 65.seconds.ago ])
                     end
									 end

					has_many :friends_for_me,
					         :through => :friendships_for_me,
					         :source => :friendshipped_by_me,
					         :conditions => 'accepted_at IS NOT NULL' do
					           def online
					             find(:all, :conditions => [ 'status <> ? AND updated_at > ?', 'offline', 65.seconds.ago ])
					           end
					         end

					has_many :pending_friends_by_me,
									 :through => :friendships_by_me,
									 :source => :friendshipped_for_me,
									 :conditions => 'accepted_at IS NULL'

					has_many :pending_friends_for_me,
									 :through => :friendships_for_me,
									 :source => :friendshipped_by_me,
									 :conditions => 'accepted_at IS NULL'

					has_many :rivaled_by_me, :foreign_key => 'user_id', :class_name => 'Rivalry'
					has_many :rivaled_for_me, :foreign_key => 'rival_id', :class_name => 'Rivalry'

					has_many :rivals_by_me,
									 :through => :rivaled_by_me,
									 :source => :rivaled_for_me do
									   def online
                       find(:all, :conditions => [ 'status <> ? AND updated_at > ?', 'offline', 65.seconds.ago ])
                     end
									 end

					has_many :rivals_for_me,
					         :through => :rivaled_for_me,
					         :source => :rivaled_by_me do
					           def online
					             find(:all, :conditions => [ 'status <> ? AND updated_at > ?', 'offline', 65.seconds.ago ])
					           end
					         end
				end
			end

    	module InstanceMethods
    	  # Returns a list of all of a users accepted friends.
    	  def friends
    	    friends_for_me + friends_by_me
    	  end

				# Returns a list of all of a users rivals.
				def rivals
					rivals_for_me + rivals_by_me
				end
    	  
    	  # Return a list of all friends who are currently online.
    	  def online_friends
    	    friends_by_me.online + friends_for_me.online
    	  end

    	  # Return a list of all rivals who are currently online.
    	  def online_rivals
    	    rivals_by_me.online + rivals_for_me.online
    	  end
    	  
    	  # Returns a list of all pending friendships.
    	  def pending_friends
    	    pending_friends_by_me + pending_friends_for_me
    	  end
    	  
    	  # Returns a full list of all pending and accepted friends.
    	  def pending_or_accepted_friends
    	    friends + pending_friends
    	  end
    	  
    	  # Accepts a user object and returns the friendship object 
    	  # associated with both users.
    	  def friendship(friend)
    	    ::Friendship.find(:first, :conditions => [ '(user_id = ? AND friend_id = ?) OR (friend_id = ? AND user_id = ?)', id, friend.id, id, friend.id ])
    	  end

    	  # Accepts a user object and returns the rivalry object 
    	  # associated with both users.
    	  def rivalry(rival)
    	    ::Rivalry.find(:first, :conditions => [ '(user_id = ? AND rival_id = ?) OR (rival_id = ? AND user_id = ?)', id, rival.id, id, rival.id ])
    	  end
    	  
    	  # Accepts a user object and returns true if both users are
    	  # friends and the friendship has been accepted.
    	  def is_friends_with?(friend)
    	    friends.include?(friend)
    	  end

    	  # Accepts a user object and returns true if both users are rivals.
    	  def is_rivals_with?(rival)
    	    rivals.include?(rival)
    	  end
    	  
    	  # Accepts a user object and returns true if both users are
    	  # friends but the friendship hasn't been accepted yet.
    	  def is_pending_friends_with?(friend)
    	    pending_friends.include?(friend)
    	  end
    	  
    	  # Accepts a user object and returns true if both users are
    	  # friends regardless of acceptance.
    	  def is_friends_or_pending_with?(friend)
    	    pending_or_accepted_friends.include?(friend)
    	  end
    	  
    	  # Accepts a user object and creates a friendship request
    	  # between both users.
    	  def request_friendship_with(friend)
					unless is_friends_or_pending_with?(friend) || self == friend
    	    	::Friendship.create!(:friendshipped_by_me => self, :friendshipped_for_me => friend)
					end
    	  end
    	  
    	  # Accepts a user object and updates an existing friendship to
    	  # be accepted.
    	  def accept_friendship_with(friend)
    	    friendship(friend).update_attribute(:accepted_at, Time.now)
    	  end
    	  
    	  # Accepts a user object and deletes a friendship between both 
    	  # users.
    	  def delete_friendship_with(friend)
    	    friendship(friend).destroy if self.is_friends_or_pending_with?(friend)
    	  end

    	  # Accepts a user object and deletes a rivalry between both 
    	  # users.
    	  def delete_rivalry_with(rival)
    	    rivalry(rival).destroy if self.is_rivals_with?(rival)
    	  end
    	  
    	  # Accepts a user object and creates a friendship between both 
    	  # users. This method bypasses the request stage and makes both
    	  # users friends without needing to be accepted.
    	  def become_friends_with(friend)
    	    unless self.is_friends_with?(friend)
    	      unless self.is_pending_friends_with?(friend)
    	        ::Friendship.create!(
								:friendshipped_by_me => self,
								:friendshipped_for_me => friend,
								:accepted_at => Time.now)
    	      else
    	        self.friendship(friend).update_attribute(:accepted_at, Time.now)
    	      end
    	    else
    	      self.friendship(friend)
    	    end
    	  end
    	  
    	  # Accepts a user object and creates a rivalry between both users.
    	  def become_rival_of(rival)
    	    unless self.is_rivals_with?(rival)
   	        ::Rivalry.create!(
							:rivaled_by_me => self,
							:rivaled_for_me => rival)
    	    else
    	      self.rivalry(rival)
    	    end
    	  end
    	end  
  	end
  end
end
