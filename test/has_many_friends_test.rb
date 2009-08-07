require File.dirname(__FILE__) + '/helper'

class FriendshipTest < Test::Unit::TestCase
	should_belong_to :friendshipped_by_me
	should_belong_to :friendshipped_for_me
end

class RivalryTest < Test::Unit::TestCase
	should_belong_to :rivaled_by_me
	should_belong_to :rivaled_for_me
end

class UserTest < Test::Unit::TestCase
	should_have_many :friendships_by_me
	should_have_many :friendships_for_me
	should_have_many :friends_by_me
	should_have_many :friends_for_me
	should_have_many :pending_friends_by_me
	should_have_many :pending_friends_for_me

	should_have_many :rivaled_by_me
	should_have_many :rivaled_for_me
	should_have_many :rivals_by_me
	should_have_many :rivals_for_me

	context "User with friends" do
		setup do
			@longbob = Factory(:user, :name => 'longbob')
			@shortbob = Factory(:user, :name => 'shortbob')
			@pendingbob = Factory(:user, :name => 'pendingbob')
			@newbob = Factory(:user, :name => 'newbob')

			Factory(:friendship,
				:user_id => @longbob.id,
				:friend_id => @shortbob.id,
				:accepted_at => DateTime.now)

			Factory(:friendship,
				:user_id => @longbob.id,
				:friend_id => @pendingbob.id)
		end

		should "have friends" do
			assert_equal 1, @longbob.friends.size
		end

		should "have online friends" do
			assert_equal 1, @longbob.online_friends.size
		end

		should "have pending friends" do
			assert_equal 1, @longbob.pending_friends.size
		end

		should "have pending and accepted friends" do
			assert_equal 2, @longbob.pending_or_accepted_friends.size
		end

		should "have a friendship relation with shortbob" do
			assert @longbob.friendship(@shortbob).is_a?(Friendship)
		end

		should "be friends with shortbob" do
			assert @longbob.is_friends_with?(@shortbob)
		end

		should "be pending friends with pendingbob" do
			assert @longbob.is_pending_friends_with?(@pendingbob)
		end

		should "be pending or friends with shortbob and pendingbob" do
			assert @longbob.is_friends_or_pending_with?(@shortbob)
			assert @longbob.is_friends_or_pending_with?(@pendingbob)
		end

		should "request friendship with another user" do
			assert @longbob.request_friendship_with(@newbob)
		end

		should "accept friendship request with another user" do
			@newbob.request_friendship_with(@longbob)
			assert @longbob.accept_friendship_with(@newbob)
		end

		should "delete friendship with shortbob" do
			assert @longbob.delete_friendship_with(@shortbob)
		end

		should "automatically be friends with newbob" do
			assert @longbob.become_friends_with(@newbob)
		end
	end

	context "User with rivals" do
		setup do
			@longbob = Factory(:user, :name => 'longbob')
			@shortbob = Factory(:user, :name => 'shortbob')

			Factory(:rivalry,
				:user_id => @longbob.id,
				:rival_id => @shortbob.id)
		end

		should "have rivals" do
			assert_equal 1, @longbob.rivals.size
		end

		should "have online rivals" do
			assert_equal 1, @longbob.online_rivals.size
		end

		should "have a rivalry relation with shortbob" do
			assert @longbob.rivalry(@shortbob).is_a?(Rivalry)
		end

		should "be rivals with shortbob" do
			assert @longbob.is_rivals_with?(@shortbob)
		end

		should "delete rivalry with shortbob" do
			assert @longbob.delete_rivalry_with(@shortbob)
		end

		should "become a rival of newbob" do
			assert @longbob.become_rival_of(@newbob)
		end
	end
end
