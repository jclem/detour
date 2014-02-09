module Detour::Flaggable
  extend ActiveSupport::Concern

  # Returns an array of all features rolled out to the given record.
  #
  # @example
  #   user.features
  #
  # @return [Array] An array of {Detour::Feature}s.
  def features
    @features ||= begin
      features = unfiltered_features
      defined_group_flags = Detour::DefinedGroupFlag.without_opt_outs(self).where("feature_id IN (?)", features.map(&:id) << -1) # Prevents NOT IN (NULL)

      defined_group_flags.each do |defined_group_flag|
        defined_group = Detour::DefinedGroup.by_type(self.class)[defined_group_flag.group_name]

        unless defined_group && defined_group.test(self)
          feeatures.delete defined_group_flag.feature
        end
      end

      features
    end
  end

  # Returns whether or not the object has access to the given feature. If given
  # a block, it will call the block if the user has access to the feature.
  #
  # @example
  #   if user.has_feature?(:new_user_interface)
  #     # ...
  #   end
  #
  # @param [Symbol] feature_name The name of the
  #   {Detour::Feature Feature} being checked.
  # @param [Proc] &block A block to be called if the user is flagged in to the
  #   feature.
  def has_feature?(feature_name, &block)
    features.map(&:name).include? feature_name.to_s
  end

  def detour_features
    @detour_features ||= []
  end

  private

  def unfiltered_features
    Detour::Feature.where(%Q{
      detour_features.id IN (
        -- Get features the record has been individually flagged in to
        SELECT feature_id FROM detour_flags
          WHERE detour_flags.type = 'Detour::FlagInFlag'
          AND   detour_flags.flaggable_type = '#{self.class.to_s}'
          AND   detour_flags.flaggable_id   = '#{id}'
      ) OR detour_features.id IN (
        -- Get features the record has been flagged into via group membership
        SELECT feature_id FROM detour_flags
          INNER JOIN detour_groups
            ON detour_groups.id = detour_flags.group_id
          INNER JOIN detour_memberships
            ON detour_memberships.group_id = detour_groups.id
            AND detour_memberships.member_id = '#{id}'
          WHERE detour_flags.type = 'Detour::DatabaseGroupFlag'
          AND   detour_flags.flaggable_type = '#{self.class}'
      ) OR detour_features.id IN (
        -- Get features the record has been flagged into via defined membership
        -- We'll test them later
        SELECT feature_id FROM detour_flags
          WHERE detour_flags.type = 'Detour::DefinedGroupFlag'
          AND   detour_flags.flaggable_type = '#{self.class}'
      ) OR detour_features.id IN (
        -- Get features the record has been flagged into via percentage
        SELECT feature_id FROM detour_flags
          WHERE detour_flags.type = 'Detour::PercentageFlag'
          AND   detour_flags.flaggable_type = '#{self.class}'
          AND   '#{id}' % 10 < detour_flags.percentage / 10
      )
    }).where(%Q{
      -- Exclude features the record has been opted out of.
      detour_features.id NOT IN (
        SELECT feature_id FROM detour_flags
          WHERE detour_flags.type = 'Detour::OptOutFlag'
          AND   detour_flags.flaggable_type = '#{self.class}'
          AND   detour_flags.flaggable_id   = '#{id}'
      )
    })
  end

  included do
    # Finds a record by the field set by the :find_by param in
    # `acts_as_flaggable`. If no :find_by param was provided, :id is used.
    #
    # @param [String,Integer] value The value to find the record by.
    def self.flaggable_find!(value)
      send("find_by_#{@detour_flaggable_find_by}!", value)
    end
  end
end
