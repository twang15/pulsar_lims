class DocumentType < ActiveRecord::Base
	has_many :documents
	belongs_to :user

	validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true

	def self.policy_class
		ApplicationPolicy
	end 
end
