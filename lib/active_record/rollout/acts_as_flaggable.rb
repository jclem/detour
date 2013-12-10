module ActiveRecord::Rollout::ActsAsFlaggable
  # Sets up ActiveRecord associations for the including class, and includes
  # {ActiveRecord::Rollout::Flaggable} in the class.
  def acts_as_flaggable
    class_eval do
      has_many :flaggable_flags,
        as: :flaggable,
        class_name: "ActiveRecord::Rollout::FlaggableFlag"

      has_many :opt_out_flags,
        as: :flaggable,
        class_name: "ActiveRecord::Rollout::OptOutFlag"

      has_many :features,
        through: :flaggable_flags,
        class_name: "ActiveRecord::Rollout::Feature"

      include ActiveRecord::Rollout::Flaggable
    end
  end
end
