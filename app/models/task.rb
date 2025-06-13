class Task < ApplicationRecord
    include Kaminari::PageScopeMethods

    validates :title, presence: true

    belongs_to :user

    paginates_per 10

    def self.ransackable_attributes(auth_object = nil)
        [ "completed", "created_at", "description", "id", "id_value", "title", "updated_at", "user_id", "title_cont", "title_or_description_cont", "completed_eq" ]
    end

    def self.ransackable_associations(auth_object = nil)
        [ "user" ]
    end
end
