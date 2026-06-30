class User < ApplicationRecord
  enum :role, {
    requester: 0,
    approver: 1,
    admin: 2
  }
  enum :status, {
    active: 0,
    inactive: 1,
    suspended: 2
  },prefix: true

  has_many:purchase_requests,
  dependent: :destroy # also use delete_all it is direct sql faster but destroy use callback 
                        #has many {DB table name} cuz it checks with exact name on db 

#without prefix, it will create methods like active?, inactive?, suspended? but it will cause conflict with others enums if they have same name to solve this we are using that prefix which makes the methods like status_active?, 
  validates :name, presence: true

  validates :email,
            presence: true,
            uniqueness: true

  validates :role, presence: true

  validates :status, presence: true



# we can also solve this without prefix by using this insted of prefix   instance_methods: false
# and by using custom methods
=begin
def active?
    status == "active"
  end

  def inactive?
    status == "inactive"
  end

  we can now call like this User.active? 
=end

end