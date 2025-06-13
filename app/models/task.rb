class Task < ApplicationRecord
    include Kaminari::PageScopeMethods
    
    validates :title, presence: true

    belongs_to :user

    paginates_per 10  

end
