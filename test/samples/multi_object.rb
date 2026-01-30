# frozen_string_literal: true

class MultiObject
  def initialize(object)
    @object = object
  end
  attr_reader :object

  def details
    object.details_for(id)
  end

  def columns
    schema.columns
  end

  def table_name
    schema.table_name
  end

  def primary_key
    schema.primary_key
  end

  def indexes
    schema.indexes
  end

  def foreign_keys
    schema.foreign_keys
  end
end
