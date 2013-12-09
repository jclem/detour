module ActiveRecord::Rollout::Flaggable
  def self.included(klass)
    klass.has_many :flags,
      as: :flag_subject,
      class_name: "ActiveRecord::Rollout::Flag"

    klass.has_many :opt_outs,
      as: :opt_out_subject,
      class_name: "ActiveRecord::Rollout::OptOut"

    klass.has_many :rollouts,
      through: :flags,
      class_name: "ActiveRecord::Rollout"
  end

  def rollout?(rollout_name)
    rollout = ActiveRecord::Rollout.find_by(name: rollout_name)
    return false unless rollout

    opt_out = opt_outs.find_by(rollout: rollout)
    return false if opt_out

    rollout.match? self
  end
end
