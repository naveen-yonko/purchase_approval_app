class PurchaseRequest < ApplicationRecord

  belongs_to :user # singular  Inflector handles this it search on its own table for col with _id for the given name i.e user

  enum :status, {
    draft: 0,
    submitted: 1,
    approved: 2,
    rejected: 3
  }
  validates :title,
          length: {
            maximum: APPROVAL_SETTINGS.dig(:approval,:max_title_length) # or APPROVAL_SETTINGS[:approval][:max_title_length]
          }

          # If the company needs to change the limit they don't need to modify the application code and change the value in multiple places across code
          # instead they can change in the configuration without changing the application code
          # so based on business requirements we can change the values instead of changing on code it is easier and safer as it reducing the risk of introducing bugs.
  validates :amount, presence: true, numericality: { greater_than: 0 }

  before_validation :set_default_status
  after_create  :log_creation
  after_save    :log_save
  after_save    :notify_on_status_change
  after_commit  :log_commit, on: [:create, :update]


  #we can also do like this -->  after_save :notify_on_status_change, if: :saved_change_to_status? so we dont need to check conditon inside the fn:


  private
  def set_default_status
    #byebug
    self.status ||= :draft
    #byebug
  end
  def log_creation
    Rails.logger.info("PurchaseRequest ##{id} created: #{title}")
  end

  def notify_on_status_change
    return unless saved_change_to_status? # use unless dont use if (!)

    old_sts, new_sts = saved_change_to_status
    Rails.logger.info("PurchaseRequest ##{id}: #{old_sts} -> #{new_sts}")
  end

  def log_save
    Rails.logger.info("PurchaseRequest ##{id} saved (status: #{status})")
  end
  def log_commit
    Rails.logger.info("PurchaseRequest ##{id} committed to DB{purchase_requests} ")
  end
  
end

