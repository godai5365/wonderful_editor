FactoryBot.define do
  factory :article do
    # title { "MyString" }
    # body { "MyText" }
    # user { nil }
    title { Faker::Lorem.word }
    # title { "name" }
    body { Faker::Lorem.sentence }
    user

    # trait :draft do
    #   status { :draft }
    # end

    # trait :published do
    #   status { :published }
    # end
  end
end
