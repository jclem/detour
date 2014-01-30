module Detour::Concerns
  module Keepable
    extend ActiveSupport::Concern

    included do
      attr_writer :to_keep
    end

    def to_keep
      @to_keep || (!marked_for_destruction? && !new_record?)
    end

    def keep_or_destroy(params = {})
      if params["to_keep"] == "1"
        self.to_keep = true
      else
        mark_for_destruction
      end
    end
  end
end
