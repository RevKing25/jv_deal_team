class Property < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :nullify
  has_many :interests, dependent: :destroy
  has_many :interested_users, through: :interests, source: :user

  validates :title, :description, :price, :street_address, :city, :state, :zip_code, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Scopes for active and expired properties
  scope :active, -> { where("expiration_date > ?", Time.current) }
  scope :expired, -> { where("expiration_date <= ?", Time.current) }

  # Instance method to check expiration
  def expired?
    expiration_date <= Time.current
  end

  def active?
    !expired?
  end

  def address
    [street_address, city, state, zip_code].compact.join(', ')
  end
  # Assuming you have image handling (e.g., Active Storage or CarrierWave)
  # If using Active Storage:
  # has_many_attached :images
  # If using CarrierWave, this might be defined differently

  mount_uploaders :images, PropertyImageUploader if defined?(PropertyImageUploader)
  mount_uploader :contract_file, ContractUploader

  US_STATES = [
    ['Alabama', 'AL'], ['Alaska', 'AK'], ['Arizona', 'AZ'], ['Arkansas', 'AR'], ['California', 'CA'],
    ['Colorado', 'CO'], ['Connecticut', 'CT'], ['Delaware', 'DE'], ['Florida', 'FL'], ['Georgia', 'GA'],
    ['Hawaii', 'HI'], ['Idaho', 'ID'], ['Illinois', 'IL'], ['Indiana', 'IN'], ['Iowa', 'IA'],
    ['Kansas', 'KS'], ['Kentucky', 'KY'], ['Louisiana', 'LA'], ['Maine', 'ME'], ['Maryland', 'MD'],
    ['Massachusetts', 'MA'], ['Michigan', 'MI'], ['Minnesota', 'MN'], ['Mississippi', 'MS'], ['Missouri', 'MO'],
    ['Montana', 'MT'], ['Nebraska', 'NE'], ['Nevada', 'NV'], ['New Hampshire', 'NH'], ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'], ['New York', 'NY'], ['North Carolina', 'NC'], ['North Dakota', 'ND'], ['Ohio', 'OH'],
    ['Oklahoma', 'OK'], ['Oregon', 'OR'], ['Pennsylvania', 'PA'], ['Rhode Island', 'RI'], ['South Carolina', 'SC'],
    ['South Dakota', 'SD'], ['Tennessee', 'TN'], ['Texas', 'TX'], ['Utah', 'UT'], ['Vermont', 'VT'],
    ['Virginia', 'VA'], ['Washington', 'WA'], ['West Virginia', 'WV'], ['Wisconsin', 'WI'], ['Wyoming', 'WY']
  ]
end