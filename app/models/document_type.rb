class DocumentType < ActiveRecord::Base
	DEFINITION = "The type of protocol."
	ABBR = "DOCTY"
	has_many :documents
	belongs_to :user

	validates :name, length: { minimum: 2, maximum: 40 }, uniqueness: true

	scope :persisted, lambda { where.not(id: nil) }

	def self.policy_class
		ApplicationPolicy
	end 
end
