class CrisprModificationSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :category, :donor_construct_id, :name, :notes, :prototype, :purpose, :times_cloned, :upstream_identifier, :created_at, :updated_at
end
