module ActiveRecord::Rollout::Flaggable
  def self.included(klass)
    klass.has_many :flags,
      as: :flag_subject,
      class_name: "ActiveRecord::Rollout::Flag"

    klass.has_many :opt_outs,
      as: :opt_out_subject,
      class_name: "ActiveRecord::Rollout::OptOut"

    klass.has_many :rollouts, through: :flags, class_name: "ActiveRecord::Rollout"
  end
end
