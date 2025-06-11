class Task < ApplicationRecord
    include Kaminari::PageScopeMethods
    
    validates :title, presence: true

    paginates_per 10  

end
