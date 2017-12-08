class Target < ActiveRecord::Base
	ABBR = "T"
	has_many :antibodies
	has_many :crispr_constructs
	has_many :donor_constructs
	belongs_to :user
	validates :encode_identifier, uniqueness: true, presence: true
	validates :name, length: { minimum: 2, maximum: 40 }, uniqueness: true

	scope :persisted, lambda { where.not(id: nil) }

	def self.policy_class
		ApplicationPolicy
	end 
end
