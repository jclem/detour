# Represents an individual feature that may be rolled out to a set of records
# via individual flags, percentages, or defined groups.
class Detour::Feature < ActiveRecord::Base
  include Detour::Concerns::Matchers
  include Detour::Concerns::FlagActions

  self.table_name = :detour_features

  serialize :flag_in_counts, JSON
  serialize :opt_out_counts, JSON

  has_many :flag_in_flags
  has_many :group_flags
  has_many :percentage_flags
  has_many :opt_out_flags
  has_many :flags, dependent: :destroy

  validates_presence_of   :name
  validates_uniqueness_of :name

  attr_accessible :name

  # Returns an instance variable intended to hold an array of the lines of code
  # that this feature appears on.
  #
  # @return [Array<String>] The lines that this rollout appears on (if
  #   {Detour::Feature.with_lines} has already been called).
  def lines
    @lines ||= []
  end

  def to_s
    name
  end

  # Returns the number of flag-ins for a given type.
  #
  # @example
  #   feature.flag_in_count_for("users")
  #
  # @return [Fixnum] The number of flag-ins for the given type.
  def flag_in_count_for(type)
    flag_in_counts[type] || 0
  end

  # Returns the number of opt-outs for a given type.
  #
  # @example
  #   feature.opt_out_count_for("users")
  #
  # @return [Fixnum] The number of opt-outs for the given type.
  def opt_out_count_for(type)
    opt_out_counts[type] || 0
  end

  # Return an array of both every feature in the database as well as every
  # feature that is checked for in `@grep_dirs`. Features that are checked
  # for but not persisted will be returned as unpersisted instances of this
  # class. Each instance returned will have its `@lines` set to an array
  # containing every line in `@grep_dirs` where it is checked for.
  #
  # @return [Array<Detour::Feature>] Every persisted and
  #   checked-for feature.
  def self.with_lines
    hash = all.each_with_object({}) { |feature, hash| hash[feature.name] = feature }

    Dir[*Detour.config.grep_dirs].each do |path|
      next unless File.file? path

      File.open path do |file|
        file.each_line.with_index(1) do |line, i|
          line.scan(/\.has_feature\?\s*\(*:(\w+)/).each do |match, _|
            (hash[match] ||= new(name: match)).lines << "#{path}#L#{i}"
          end
        end
      end
    end

    hash.values.sort_by(&:name)
  end
end
