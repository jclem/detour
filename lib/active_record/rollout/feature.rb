class ActiveRecord::Rollout::Feature < ActiveRecord::Base
  @@defined_groups = {}

  self.table_name = :active_record_rollout_features

  has_many :flags, dependent: :destroy
  has_many :opt_outs, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def match?(instance)
    match_instance?(instance) || match_percentage?(instance) || match_groups?(instance)
  end

  def match_instance?(instance)
    flags.where(flag_subject_type: instance.class, flag_subject_id: instance.id).any?
  end

  def match_percentage?(instance)
    percentage = flags.where("percentage_type = ? AND percentage IS NOT NULL", instance.class.to_s).first.try(:percentage)
    instance.id % 10 < (percentage || 0) / 10
  end

  def match_groups?(instance)
    klass = instance.class.to_s

    return unless self.class.defined_groups[klass]

    group_names = flags.where("group_type = ? AND group_name IS NOT NULL", klass).collect(&:group_name)

    self.class.defined_groups[klass].select { |key, value|
      group_names.map.include? key.to_s
    }.collect { |key, value|
      value.call(instance)
    }.any?
  end

  def self.configure(&block)
    yield self
  end

  def self.defined_groups
    @@defined_groups
  end

  def self.create_flag_from_instance(instance, flag_name)
    feature = find_by_name!(flag_name)
    feature.flags.create!(flag_subject: instance)
  end

  def self.remove_flag_from_instance(instance, flag_name)
    feature = find_by_name!(flag_name)
    feature.flags.where(flag_subject_type: instance.class, flag_subject_id: instance.id).destroy_all
  end

  def self.define_group_for_class(klass, group_name, &block)
    @@defined_groups[klass] ||= {}
    @@defined_groups[klass][group_name] = block
  end

  def self.method_missing(method, *args, &block)
    if method =~ /^add_.*/
      create_flag_from_instance(args[0], args[1])
    elsif method =~ /^remove_.*/
      remove_flag_from_instance(args[0], args[1])
    elsif /^define_(?<klass>[a-z0-9_]+)_group/ =~ method
      define_group_for_class(klass.classify, args[0], &block)
    else
      super
    end
  end
end
