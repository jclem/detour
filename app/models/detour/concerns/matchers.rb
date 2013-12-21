module Detour::Concerns
  module Matchers
    # Determines whether or not the given instance has had the feature rolled out
    # to it either via direct flagging-in, percentage, or by group membership.
    #
    # @example
    #   feature.match?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it.
    def match?(instance)
      match_id?(instance) || match_percentage?(instance) || match_groups?(instance)
    end

    # Determines whether or not the given instance has had the feature rolled out
    # to it via direct flagging-in.
    #
    # @example
    #   feature.match_id?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it
    #   via direct flagging-in.
    def match_id?(instance)
      flag_in_flags.where(flaggable_type: instance.class.to_s, flaggable_id: instance.id).any?
    end

    # Determines whether or not the given instance has had the feature rolled out
    # to it via percentage.
    #
    # @example
    #   feature.match_percentage?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it
    #   via direct percentage.
    def match_percentage?(instance)
      flag = percentage_flags.find(:first, conditions: ["flaggable_type = ?", instance.class.to_s])
      percentage = flag ? flag.percentage : 0

      instance.id % 10 < percentage / 10
    end

    # Determines whether or not the given instance has had the feature rolled out
    # to it via group membership.
    #
    # @example
    #   feature.match_groups?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it
    #   via direct group membership.
    def match_groups?(instance)
      klass = instance.class.to_s

      return unless Detour.config.defined_groups[klass]

      group_names = group_flags.find_all_by_flaggable_type(klass).collect(&:group_name)

      Detour.config.defined_groups[klass].collect { |group_name, block|
        block.call(instance) if group_names.include? group_name
      }.any?
    end
  end
end
