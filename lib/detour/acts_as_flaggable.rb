module Detour::ActsAsFlaggable
  # Sets up ActiveRecord associations for the including class, and includes
  # {Detour::Flaggable} in the class.
  #
  # @example
  #   class User < ActiveRecord::Base
  #     acts_as_taggable find_by: :email
  #   end
  #
  # @option options [Symbol] :find_by The field to find the record by when
  #   running rake tasks. Defaults to :id.
  def acts_as_flaggable(options = {})
    Detour::Feature.class_eval <<-EOF
      has_one :#{table_name}_percentage_flag,
        class_name: "Detour::PercentageFlag",
        dependent:  :destroy,
        inverse_of: :feature,
        conditions: { flaggable_type: "#{self}" }

      attr_accessible :#{table_name}_percentage_flag_attributes
      accepts_nested_attributes_for :#{table_name}_percentage_flag, reject_if: :all_blank

      def #{table_name}_percentage_flag
        super || build_#{table_name}_percentage_flag
      end
    EOF

    class_eval do
      @detour_flaggable_find_by = :id

      has_many :flaggable_flags,
        as: :flaggable,
        class_name: "Detour::FlaggableFlag"

      has_many :opt_out_flags,
        as: :flaggable,
        class_name: "Detour::OptOutFlag"

      has_many :features,
        through: :flaggable_flags,
        class_name: "Detour::Feature"

      if options[:find_by]
        @detour_flaggable_find_by = options[:find_by]
      end

      extend  Detour::Flaggable::ClassMethods
      include Detour::Flaggable
    end
  end
end
