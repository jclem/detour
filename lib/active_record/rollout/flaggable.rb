# Can be included in an `ActiveRecord::Base` so that features can be rolled out
# to records of the class.
#
# @example
#   class User < ActiveRecord::Base
#     include ActiveRecord::Rollout::Flaggable
#   end
module ActiveRecord::Rollout::Flaggable
  # Sets up ActiveRecord associations for the including class.
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

  # Returns whether or not the object has access to the given feature. If given
  # a block, it will call the block if the user has access to the feature.
  #
  # If an exception is raised in the block, it will increment the
  # `failure_count` of the feature and raise the exception.
  #
  # @example
  #   # Exceptions will be tracked in the `failure_count` of :new_user_interface.
  #   user.feature?(:new_user_interface) do
  #     # ...
  #   end
  #
  # @example
  #   # Exceptions will *not* be tracked in the `failure_count` of :new_user_interface.
  #   if user.feature?(:new_user_interface)
  #     # ...
  #   end
  #
  # @param [Symbol] feature_name The name of the
  #   {ActiveRecord::Rollout::Feature Feature} being checked.
  # @param [Proc] &block A block to be called if the user is flagged in to the
  #   feature.
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
