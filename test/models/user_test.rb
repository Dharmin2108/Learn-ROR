# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = build(:user)
  end

  # embed new test cases here...
  def test_user_should_be_not_be_valid_without_name
    @user.name = ""
    assert_not @user.valid?
    assert_equal ["Name can't be blank"], @user.errors.full_messages
  end

  def test_name_should_be_of_valid_length
    @user.name = "a" * 50
    assert_not @user.invalid?
  end

  def test_user_should_be_not_be_valid_and_saved_without_email
    @user.email = ""
    assert_not @user.valid?

    @user.save
    assert_equal ["Email can't be blank", "Email is invalid"],
                   @user.errors.full_messages
  end

  def test_user_should_not_be_valid_and_saved_if_email_not_unique
    @user.save!

    test_user = @user.dup
    assert_not test_user.valid?

    assert_equal ["Email has already been taken"],
                   test_user.errors.full_messages
  end

  def test_reject_email_of_invalid_length
    @user.email = ("a" * 50) + "@test.com"
    assert @user.invalid?
  end

  def test_validation_should_accept_valid_addresses
    valid_emails = %w[user@example.com USER@example.COM US-ER@example.org
                        first.last@example.in user+one@example.ac.in]

    valid_emails.each do |email|
      @user.email = email
      assert @user.valid?
    end
  end

  def test_validation_should_reject_invalid_addresses
    invalid_emails = %w[user@example,com user_at_example.org user.name@example.
                          @sam-sam.com sam@sam+exam.com fishy+#.com]

    invalid_emails.each do |email|
      @user.email = email
      assert @user.invalid?
    end
  end

  def test_user_should_not_be_saved_without_password
    @user.password = nil
    assert_not @user.save
    assert_equal ["Password can't be blank"],
                   @user.errors.full_messages
  end

  def test_user_should_match_password_and_password_confirmation
    @user.password_confirmation = ""
    assert_not @user.save
    assert_equal ["Password confirmation doesn't match Password", "Password confirmation can't be blank"],
                   @user.errors.full_messages
  end

  def test_users_should_have_unique_auth_token
    @user.save!
    second_user = create(:user)

    assert_not_same @user.authentication_token,
                      second_user.authentication_token
  end

  def test_preference_created_is_valid
    @user.save
    assert @user.preference.valid?
  end

  def test_notification_delivery_hour_uses_default_value
    @user.save
    assert_equal @user.preference.notification_delivery_hour, Constants::DEFAULT_NOTIFICATION_DELIVERY_HOUR
  end
end

