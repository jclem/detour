class Detour::Configuration
  attr_reader   :defined_groups
  attr_reader   :feature_search_regex
  attr_accessor :default_flaggable_class_name
  attr_accessor :flaggable_types
  attr_accessor :grep_dirs

  def initialize
    @defined_groups       = {}
    @flaggable_types      = []
    @grep_dirs            = []
  end

  # Defines the regular expression used to search for features. It must include
  # a single match group.
  #
  # @example
  #   Detour.config.feature_search_regex = /\.rollout\? :(\w+)/
  #
  # @param [Regexp] regex A regex to use to search for feature checks with.
  def feature_search_regex=(regex)
    if regex.is_a? Regexp
      @feature_search_regex = regex
    else
      raise "Feature search regex must be an instance of Regexp"
    end
  end

  # Allows for methods of the form `define_user_group` that call the private
  # method `define_group_for_class`. A new group for any `User` records will
  # be created that rollouts can be attached to.
  #
  # @example
  #   Detour.config.define_user_group :admins do |user|
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
    @defined_groups[klass][group_name] = Detour::DefinedGroup.new(group_name, block)
  end
end
