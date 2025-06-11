FactoryBot.define do
    factory :task do
        title { "Task #{Faker::Lorem.word}" }
        description { Faker::Lorem.sentence }
        completed { false }
    end
end