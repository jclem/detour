module ActiveRecord::Rollout::Flaggable
  def self.included(klass)
    klass.has_many :flags,
      as: :flag_subject,
      class_name: "ActiveRecord::Rollout::Flag"

    klass.has_many :opt_outs,
      as: :opt_out_subject,
      class_name: "ActiveRecord::Rollout::OptOut"

    klass.has_many :features,
      through: :flags,
      class_name: "ActiveRecord::Rollout::Feature"
  end

  def feature?(feature_name, &block)
    feature = ActiveRecord::Rollout::Feature.find_by_name(feature_name)
    return false unless feature

    opt_out = opt_outs.find_by_feature_id(feature.id)
    return false if opt_out

    match = feature.match? self

    if match && block_given?
      begin
        block.call
      rescue => e
        feature.increment! :failure_count
        raise e
      end
    else
      match
    end
  end
end
