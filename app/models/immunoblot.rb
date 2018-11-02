require 'elasticsearch/model'
class Immunoblot < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include ModelConcerns
  ABBR = "IB"
  DEFINITION = "Immunoblot. Model abbreviation: #{ABBR}"

  belongs_to :analyst, class_name: "User"
  has_one :gel, dependent: :nullify    
  belongs_to :primary_antibody, class_name: "Antibody"
  has_and_belongs_to_many :secondary_antibodies, class_name: "Antibody", join_table: :immunoblots_secondary_antibodies, foreign_key: :immunoblot_id, association_foreign_key: :secondary_antibody_id
  belongs_to :secondary_antibody, class_name: "Antibody"
  belongs_to :user
  has_and_belongs_to_many :documents
  has_many :biosamples, through: :gel

  validates :primary_antibody, presence: {message: "must be specified when 'primary antibody dilution' is specified."}, if: "primary_antibody_dilution.present?"
  validates :secondary_antibody, presence: {message: "must be specified when 'secondary antibody dilution' is specified."}, if: "secondary_antibody_dilution.present?"

  accepts_nested_attributes_for :documents, allow_destroy: true

  scope :persisted, lambda { where.not(id: nil) }

  def self.policy_class
    ApplicationPolicy
  end

  def display
    self.get_record_id()
  end

  def document_ids=(ids)
    """
    Function : Adds associations to Documents that are stored in self.documents.
    Args     : ids - array of Document IDs.
    """
    ids.each do |i|
      if i.blank?
        next
      end
      doc = Document.find(i)
      if not self.documents.include? doc
        self.documents << doc
      end
    end
  end

  private
end
