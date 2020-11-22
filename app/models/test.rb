# frozen_string_literal: true

# SimpleRackFramework.application.db.create_table(:tests) do
#   primary_key :id
#   String :title, null: false
#   Integer :level, default: 0
# end

class Test < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :title
  end

  def to_json(*_args)
    { id: id, title: title, level: level }
  end
end
