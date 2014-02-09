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
      @features = []

      opt_out_ids = opt_out_flags.map(&:feature_id)
      table_name = self.class.table_name

      database_group_features = Detour::Feature.joins(:"#{table_name}_database_group_flags" => :memberships).where("detour_memberships" => { member_id: self.id }).where("'detour_features'.id NOT IN (?)", opt_out_ids)
      @features.concat database_group_features

      defined_group_features = Detour::Feature.joins(:"#{table_name}_defined_group_flags").where("'detour_features'.id NOT IN (?)", @features.map(&:id)).where("'detour_features'.id NOT IN (?)", opt_out_ids)
      @features.concat defined_group_features.select { |feature| feature.match_defined_groups?(self) }

      percentage_group_features = Detour::Feature.joins(:"#{table_name}_percentage_flag").where("'detour_features'.id NOT IN (?)", @features.map(&:id)).where("'detour_features'.id NOT IN (?)", opt_out_ids)
      @features.concat percentage_group_features.select { |feature| feature.match_percentage?(self) }

      flag_in_features = Detour::Feature.joins(:"#{table_name}_flag_ins").where("'detour_features'.id NOT IN (?)", @features.map(&:id)).where("'detour_features'.id NOT IN (?)", opt_out_ids)
      @features.concat flag_in_features
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
    if detour_features.include? feature_name.to_s
      match = true
    else
      feature = Detour::Feature.find_by_name(feature_name)
      return false unless feature

      opt_out = opt_out_flags.find_by_feature_id(feature.id)
      return false if opt_out

      match = feature.match? self

      if match
        detour_features << feature.name.to_s
      end
    end

    match
  end

  def detour_features
    @detour_features ||= []
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
