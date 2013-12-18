# Represents an individual feature that may be rolled out to a set of records
# via individual flags, percentages, or defined groups.
class Detour::Feature < ActiveRecord::Base
  # A hash representing the groups that have been defined.
  @defined_groups = {}

  # Directories to grep for feature tests
  @grep_dirs  = []

  self.table_name = :detour_features

  has_many :flaggable_flags
  has_many :group_flags
  has_many :percentage_flags
  has_many :opt_out_flags
  has_many :flags, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  attr_accessible :name

  # Returns an instance variable intended to hold an array of the lines of code
  # that this feature appears on.
  #
  # @return [Array<String>] The lines that this rollout appears on (if
  #   {Detour::Feature.all_with_lines} has already been called).
  def lines
    @lines ||= []
  end

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
    flaggable_flags.where(flaggable_type: instance.class.to_s, flaggable_id: instance.id).any?
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

    return unless self.class.defined_groups[klass]

    group_names = group_flags.find_all_by_flaggable_type(klass).collect(&:group_name)

    self.class.defined_groups[klass].collect { |group_name, block|
      block.call(instance) if group_names.include? group_name
    }.any?
  end

  class << self
    # Returns the defined groups.
    def defined_groups
      @defined_groups
    end

    # Returns the default flaggable class.
    def default_flaggable_class_name
      @default_flaggable_class_name
    end

    # Sets the default flaggable class.
    def default_flaggable_class_name=(klass)
      @default_flaggable_class_name = klass
    end

    # A list of directories to search through when finding feature checks.
    def grep_dirs
      @grep_dirs
    end

    # Set the list of directories to search through when finding feature checks.
    def grep_dirs=(grep_dirs)
      @grep_dirs = grep_dirs
    end

    # Return an array of both every feature in the database as well as every
    # feature that is checked for in `@grep_dirs`. Features that are checked
    # for but not persisted will be returned as unpersisted instances of this
    # class. Each instance returned will have its `@lines` set to an array
    # containing every line in `@grep_dirs` where it is checked for.
    #
    # @return [Array<Detour::Feature>] Every persisted and
    #   checked-for feature.
    def all_with_lines
      obj = all.each_with_object({}) { |feature, obj| obj[feature.name] = feature }

      Dir[*@grep_dirs].each do |path|
        next if File.directory? path

        File.open path do |file|
          file.each_line.with_index(1) do |line, i|
            line.scan(/\.has_feature\?\s*\(*:(\w+)/).each do |match|
              match = match[0]
              obj[match] ||= find_or_initialize_by_name(match)
              obj[match].lines << "#{path}#L#{i}"
            end
          end
        end
      end

      obj.values
    end

    # Add a record to the given feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   Detour::Feature.add_record_to_feature user, :new_ui
    #
    # @param [ActiveRecord::Base] record A record to add the feature to.
    # @param [String,Symbol] feature_name The feature to be added to the record.
    #
    # @return [Detour::Flag] The
    #   {Detour::Flag Flag} created.
    def add_record_to_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.flaggable_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).first_or_create!
    end

    # Remove a record from the given feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   Detour::Feature.remove_record_from_feature user, :new_ui
    #
    # @param [ActiveRecord::Base] record A record to remove the feature from.
    # @param [String,Symbol] feature_name The feature to be removed from the
    #   record.
    def remove_record_from_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.flaggable_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).destroy_all
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
    #   Detour::Feature.opt_record_out_of_feature user, :new_ui
    #
    # @return [Detour::OptOut] The
    #   {Detour::OptOut OptOut} created.
    def opt_record_out_of_feature(record, feature_name)
      feature = find_by_name!(feature_name)
      feature.opt_out_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).first_or_create!
    end

    # Remove any opt out for the given record out of a feature. If the feature
    # is not found, an ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   Detour::Feature.un_opt_record_out_of_feature user, :new_ui
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
    #   Detour::Feature.add_group_to_feature "User", "admin", :delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the group
    #   should be associated with.
    # @param [String] group_name The name of the group to have the feature
    #   added to it.
    # @param [String,Symbol] feature_name The feature to be added to the group.
    #
    # @return [Detour::Flag] The
    #   {Detour::Flag Flag} created.
    def add_group_to_feature(flaggable_type, group_name, feature_name)
      feature = find_by_name!(feature_name)
      feature.group_flags.where(flaggable_type: flaggable_type, group_name: group_name).first_or_create!
    end

    # Remove a group from agiven feature. If the feature is not found, an
    # ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   Detour::Feature.remove_group_from_feature "User", "admin", :delete_records
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
    #   Detour::Feature.add_percentage_to_feature "User", 75, :delete_records
    #
    # @param [String] flaggable_type The class (as a string) that the percetnage
    #   should be associated with.
    # @param [Integer] percentage The percentage of `flaggable_type` records
    #   that the feature will be available for.
    # @param [String,Symbol] feature_name The feature to be added to the
    #   percentage of records.
    #
    # @return [Detour::Flag] The
    #   {Detour::Flag Flag} created.
    def add_percentage_to_feature(flaggable_type, percentage, feature_name)
      feature = find_by_name!(feature_name)

      flag = feature.percentage_flags.where(flaggable_type: flaggable_type).first_or_initialize
      flag.update_attributes!(percentage: percentage)
    end

    # Remove any percentage flags for the given feature. If the feature is not
    # found, an ActiveRecord::RecordNotFound will be raised.
    #
    # @example
    #   Detour::Feature.remove_percentage_from_feature "User", delete_records
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
    #   Detour::Feature.define_user_group :admins do |user|
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
      @defined_groups[klass] ||= {}
      @defined_groups[klass][group_name] = block
    end
  end
end
