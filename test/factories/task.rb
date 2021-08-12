# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    user
    title { Faker::Lorem.sentence }
    progress { "pending" }
    status { "unstarred" }
  end
end

