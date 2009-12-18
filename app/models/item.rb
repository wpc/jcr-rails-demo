class Item < JCR::RecordBase
  versionable
  
  has_property :name
  has_property :attr_bool, :boolean
  has_property :attr_long, :long
end