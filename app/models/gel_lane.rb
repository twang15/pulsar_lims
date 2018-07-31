require 'elasticsearch/model'
class GelLane < ActiveRecord::Base
  include Elasticsearch::Model                                                                         
  include Elasticsearch::Model::Callbacks                                                              
  include ModelConcerns 
  ABBR = "GL"                                                                                          
  DEFINITION = "Represents a lane from an aragose gel."

  belongs_to :agarose_gel
  belongs_to :user
  belongs_to :sample_concentration_units, class_name: "ConcentrationUnit"

  validates :lane_number, presence: true
  validates_uniqueness_of :lane_number, scope: [:agarose_gel]
  validates :sample_concentration, presence: true
  validates :sample_concentration_units_id, presence: true

  scope :persisted, lambda { where.not(id: nil) }

  def self.policy_class                                                                                
    ApplicationPolicy                                                                                  
  end 

  def display
    self.lane_number
  end
end
