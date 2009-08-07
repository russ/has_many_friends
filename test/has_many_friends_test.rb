require File.dirname(__FILE__) + '/helper'

class FriendshipTest < Test::Unit::TestCase
	should_belong_to :friendshipped_by_me
	should_belong_to :friendshipped_for_me
end

class UserTest < Test::Unit::TestCase
	should_have_many :friendships_by_me
	should_have_many :friendships_for_me
	should_have_many :friends_by_me
	should_have_many :friends_for_me
	should_have_many :pending_friends_by_me
	should_have_many :pending_friends_for_me

	context "User with friends" do
		setup do
			@longbob = Factory(:user, :name => 'Longbob')
			@shortbob = Factory(:user, :name => 'ShortBob')
			@pendingbob = Factory(:user, :name => 'PendingBob')
			@newbob = Factory(:user, :name => 'NewBob')

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
end
