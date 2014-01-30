module Detour::Concerns
  module Matchers
    # Determines whether or not the given instance has had the feature rolled out
    # to it either via direct flagging-in, percentage, or by database or defined
    # group membership.
    #
    # @example
    #   feature.match?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it.
    def match?(instance)
      match_id?(instance)                ||
        match_percentage?(instance)      ||
        match_database_groups?(instance) ||
        match_defined_groups?(instance)
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
    # to it via database group membership.
    #
    # @example
    #   feature.match_database_groups?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it
    #   via direct database group membership.
    def match_database_groups?(instance)
      database_group_flags.where(flaggable_type: instance.class).map(&:members).flatten.uniq.include? instance
    end

    # Determines whether or not the given instance has had the feature rolled out
    # to it via defined group membership.
    #
    # @example
    #   feature.match_defined_groups?(current_user)
    #
    # @param [ActiveRecord::Base] instance A record to be tested for feature
    #   rollout.
    #
    # @return Whether or not the given instance has the feature rolled out to it
    #   via direct group membership.
    def match_defined_groups?(instance)
      klass = instance.class.to_s

      return unless Detour::DefinedGroup.by_type(klass).any?

      group_names = defined_group_flags.find_all_by_flaggable_type(klass).collect(&:group_name)

      Detour::DefinedGroup.by_type(klass).collect { |group|
        group.test(instance) if group_names.include? group.name
      }.any?
    end
  end
end
