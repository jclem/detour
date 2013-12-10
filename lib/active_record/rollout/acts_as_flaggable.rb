module ActiveRecord::Rollout::ActsAsFlaggable
  # Sets up ActiveRecord associations for the including class, and includes
  # {ActiveRecord::Rollout::Flaggable} in the class.
  #
  # @example
  #   class User < ActiveRecord::Base
  #     acts_as_taggable find_by: :email
  #   end
  #
  # @option options [Symbol] :find_by The field to find the record by when
  #   running rake tasks. Defaults to :id.
  def acts_as_flaggable(options = {})
    class_eval do
      @active_record_rollout_flaggable_find_by = :id

      has_many :flaggable_flags,
        as: :flaggable,
        class_name: "ActiveRecord::Rollout::FlaggableFlag"

      has_many :opt_out_flags,
        as: :flaggable,
        class_name: "ActiveRecord::Rollout::OptOutFlag"

      has_many :features,
        through: :flaggable_flags,
        class_name: "ActiveRecord::Rollout::Feature"

      if options[:find_by]
        @active_record_rollout_flaggable_find_by = options[:find_by]
      end

      extend  ActiveRecord::Rollout::Flaggable::ClassMethods
      include ActiveRecord::Rollout::Flaggable
    end
  end
end
