class Detour::DefinedGroup
  attr_reader :name
  alias :id :name

  def initialize(name, test)
    @name = name.to_s
    @test = test
  end

  def to_s
    name
  end

  def test(arg)
    @test.call(arg)
  end

  def self.by_type(type)
    Detour.config.defined_groups.fetch(type.to_s, {}).with_indifferent_access
  end
end
