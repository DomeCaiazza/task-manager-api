FactoryBot.define do
    factory :task do
        title { Faker::Lorem.sentence }
        description { Faker::Lorem.paragraph }
        completed { false }
        association :user
    end
end
