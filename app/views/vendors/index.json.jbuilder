json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :upstream_identifier, :name, :description
  json.url vendor_url(vendor, format: :json)
end
