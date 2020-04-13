class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  has_many :modes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :achievement_grants, dependent: :destroy
  has_many :achievements, through: :achievement_grants

  def to_simple
    {
      id: id,
      name: name,
      created_at: created_at,
      admin: admin
    }
  end
end
