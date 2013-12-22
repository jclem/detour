module Detour::Concerns
  module CountableFlag
    extend ActiveSupport::Concern

    included do
      after_save    :step_count
      after_destroy :step_count

      private

      def step_count
        count = feature.send("#{flag_type}_count_for", flaggable_type.tableize)
        count = destroyed? ? count - 1 : count + 1
        feature.send("#{flag_type}_counts")[flaggable_type.tableize] = count
        feature.save!
      end
    end
  end
end
