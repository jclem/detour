module Detour::Concerns
  module FlagActions
    extend ActiveSupport::Concern

    module ClassMethods
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
        feature.flag_in_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).first_or_create!
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
        feature.flag_in_flags.where(flaggable_type: record.class.to_s, flaggable_id: record.id).destroy_all
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
        feature.defined_group_flags.where(flaggable_type: flaggable_type, group_name: group_name).first_or_create!
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
        feature.defined_group_flags.where(flaggable_type: flaggable_type, group_name: group_name).destroy_all
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
    end
  end
end
