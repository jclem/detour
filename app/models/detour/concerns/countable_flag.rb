module Detour::Concerns
  module CountableFlag
    extend ActiveSupport::Concern

    included do
      after_save do
        count = feature.send("#{flag_type}_count_for", flaggable_type.tableize)
        feature.send("#{flag_type}_counts")[flaggable_type.tableize] = count + 1
        feature.save!
      end

      after_destroy do
        count = feature.send("#{flag_type}_count_for", flaggable_type.tableize)
        feature.send("#{flag_type}_counts")[flaggable_type.tableize] = count - 1
        feature.save!
      end
    end
  end
end
