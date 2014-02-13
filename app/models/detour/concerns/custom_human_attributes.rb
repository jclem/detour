module Detour::Concerns
  module CustomHumanAttributes
    extend ActiveSupport::Concern

    included do
      @human_attribute_names = {}

      class << self
        alias :original_human_attribute_name :human_attribute_name
      end

      def self.human_attribute_name(*args)
        @human_attribute_names[args[0]] || original_human_attribute_name(*args)
      end

      def self.set_human_attribute_name(key, name)
        @human_attribute_names[key] = name
      end
    end
  end
end
