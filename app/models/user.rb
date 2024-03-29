# frozen_string_literal: true

class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze

  has_many :comments, dependent: :destroy
  has_many :tasks, dependent: :destroy, foreign_key: :user_id
  has_many :user_notifications, dependent: :destroy, foreign_key: :user_id
  has_one :preference, dependent: :destroy, foreign_key: :user_id
  has_secure_password
  has_secure_token :authentication_token

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true,
                    uniqueness: true,
                    length: { maximum: 50 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true, on: :create

  before_save :to_lowercase
  before_create :build_default_preference

  private

    def to_lowercase
      email.downcase!
    end

    def build_default_preference
      self.build_preference(notification_delivery_hour: Constants::DEFAULT_NOTIFICATION_DELIVERY_HOUR)
    end
end

