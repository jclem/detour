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

  def rollout?(rollout_name, &block)
    rollout = ActiveRecord::Rollout.find_by(name: rollout_name)
    return false unless rollout

    opt_out = opt_outs.find_by(rollout: rollout)
    return false if opt_out

    match = rollout.match? self

    if match && block_given?
      begin
        block.call
      rescue => e
        rollout.increment! :failure_count
        raise e
      end
    else
      match
    end
  end
end
