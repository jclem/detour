module Detour::Concerns
  module Keepable
    extend ActiveSupport::Concern

    included do
      attr_writer :to_keep
    end

    def to_keep
      @to_keep || (!marked_for_destruction? && !new_record?)
    end
  end
end
