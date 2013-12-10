# Represents an individual feature that may be rolled out to a set of records
# via individual flags, percentages, or defined groups.
class ActiveRecord::Rollout::Feature < ActiveRecord::Base
  # A hash representing the groups that have been defined.
  @@defined_groups = {}

  self.table_name = :active_record_rollout_features

  has_many :flaggable_flags
  has_many :group_flags
  has_many :percentage_flags
  has_many :opt_out_flags
  has_many :flags, dependent: :destroy

  validates :name, presence: true, uniqueness: true

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
    flaggable_flags.where(flaggable_type: instance.class, flaggable_id: instance.id).any?
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
    percentage = percentage_flags.where("flaggable_type = ?", instance.class.to_s).first.try(:percentage)
    instance.id % 10 < (percentage || 0) / 10
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

    return unless self.class.defined_groups[klass]

    group_names = group_flags.where("flaggable_type = ?", klass).collect(&:group_name)

    self.class.defined_groups[klass].select { |key, value|
      group_names.map.include? key.to_s
    }.collect { |key, value|
      value.call(instance)
    }.any?
  end

  class << self
    # Returns the defined groups.
    def defined_groups
      @@defined_groups
    end

    # Add a record to the given feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.add_record_to_feature user, :new_ui
    #
    # @param [ActiveRecord::Base] record A record to add the feature to.
    # @param [String,Symbol] feature_name The feature to be added to the record.
    #
    # @return [ActiveRecord::Rollout::Flag] The
    #   {ActiveRecord::Rollout::Flag Flag} created.
    def add_record_to_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.flaggable_flags.create!(flaggable: record)
    end

    # Remove a record from the given feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.remove_record_from_feature user, :new_ui
    #
    # @param [ActiveRecord::Base] record A record to remove the feature from.
    # @param [String,Symbol] feature_name The feature to be removed from the
    #   record.
    def remove_record_from_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.flaggable_flags.where(flaggable_type: record.class, flaggable_id: record.id).destroy_all
    end

    # Opt the given record out of a feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised. An opt out ensures that no
    # matter what, `record.rollout?(:rollout)` will always return false for any
    # opted-out-of features.
    #
    # @param [ActiveRecord::Base] record A record to opt out of the feature.
    # @param [String,Symbol] feature_name The feature to be opted out of.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.opt_record_out_of_feature user, :new_ui
    #
    # @return [ActiveRecord::Rollout::OptOut] The
    #   {ActiveRecord::Rollout::OptOut OptOut} created.
    def opt_record_out_of_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.opt_out_flags.create!(flaggable_type: record.class.to_s, flaggable_id: record.id)
    end

    # Remove any opt out for the given record out of a feature. If the feature
    # is not found, an ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.un_opt_record_out_of_feature user, :new_ui
    #
    # @param [ActiveRecord::Base] record A record to un-opt-out of the feature.
    # @param [String,Symbol] feature_name The feature to be un-opted-out of.
    def un_opt_record_out_of_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.opt_out_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).destroy_all
    end

    # Add a group to the given feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.add_group_to_feature "User", "admin", :delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the group
    #   should be associated with.
    # @param [String] group_name The name of the group to have the feature
    #   added to it.
    # @param [String,Symbol] feature_name The feature to be added to the group.
    #
    # @return [ActiveRecord::Rollout::Flag] The
    #   {ActiveRecord::Rollout::Flag Flag} created.
    def add_group_to_feature(flaggable_type, group_name, feature_name)
      feature = find_by_name!(feature_name)
      feature.group_flags.create!(flaggable_type: flaggable_type, group_name: group_name)
    end

    # Remove a group from agiven feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.remove_group_from_feature "User", "admin", :delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the group should
    #   be removed from.
    # @param [String] group_name The name of the group to have the feature
    #   removed from it.
    # @param [String,Symbol] feature_name The feature to be removed from the
    #   group.
    def remove_group_from_feature(flaggable_type, group_name, feature_name)
      feature = find_by_name!(feature_name)
      feature.group_flags.where(flaggable_type: flaggable_type, group_name: group_name).destroy_all
    end

    # Add a percentage of records to the given feature. If the feature is not
    # found, an ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.add_percentage_to_feature "User", 75, :delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the percetnage
    #   should be associated with.
    # @param [Integer] percentage The percentage of `flaggable_type` records
    #   that the feature will be available for.
    # @param [String,Symbol] feature_name The feature to be added to the
    #   percentage of records.
    #
    # @return [ActiveRecord::Rollout::Flag] The
    #   {ActiveRecord::Rollout::Flag Flag} created.
    def add_percentage_to_feature(flaggable_type, percentage, feature_name)
      feature = find_by_name!(feature_name)
      feature.percentage_flags.create!(flaggable_type: flaggable_type, percentage: percentage)
    end

    # Remove any percentage flags for the given feature. If the feature is not
    # found, an ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.remove_percentage_from_feature "User", delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the percetnage
    #   should be removed from.
    # @param [String,Symbol] feature_name The feature to have the percentage
    #   flag removed from.
    def remove_percentage_from_feature(flaggable_type, feature_name)
      feature = find_by_name!(feature_name)
      feature.percentage_flags.where(flaggable_type: flaggable_type).destroy_all
    end

    # Allows for methods of the form `define_user_group` that call the private
    # method `define_group_for_class`. A new group for any `User` records will
    # be created that rollouts can be attached to.
    #
    # @example
    #   ActiveRecord::Rollout::Feature.define_user_group :admins do |user|
    #     user.admin?
    #   end
    def method_missing(method, *args, &block)
      if /^define_(?<klass>[a-z0-9_]+)_group/ =~ method
        define_group_for_class(klass.classify, args[0], &block)
      else
        super
      end
    end

    private

    def define_group_for_class(klass, group_name, &block)
      @@defined_groups[klass] ||= {}
      @@defined_groups[klass][group_name] = block
    end
  end
end
