module Detour::Flaggable
  extend ActiveSupport::Concern

  # Returns an array of all features rolled out to the given record.
  #
  # @example
  #   user.detour_features
  #
  # @return [Array] An array of {Detour::Feature}s.
  def detour_features
    @detour_features ||= begin
      features = unfiltered_features
      defined_group_flags = Detour::DefinedGroupFlag.without_opt_outs(self).where("feature_id IN (?)", features.map(&:id) << -1) # Prevents NOT IN (NULL)

      defined_group_flags.each do |defined_group_flag|
        defined_group = Detour::DefinedGroup.by_type(self.class)[defined_group_flag.group_name]

        unless defined_group && defined_group.test(self)
          features.delete defined_group_flag.feature
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
    detour_features.map(&:name).include? feature_name.to_s
  end

  private

  def unfiltered_features
    table = Detour::Feature.arel_table
    query = table[:id].in(flag_in_flags.select(:feature_id).arel)
      .or(table[:id].in(database_group_flags.select(:feature_id).arel))
      .or(table[:id].in(defined_group_flags.select(:feature_id).arel))
      .or(table[:id].in(percentage_flags.select(:feature_id).arel))
      .and(table[:id].not_in(opt_out_flags.select(:feature_id).arel))

    Detour::Feature.where(query)
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
