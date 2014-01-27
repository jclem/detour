class Detour::DefinedGroup
  attr_reader :name

  def initialize(name, test)
    @name = name.to_s
    @test = test
  end

  def test(arg)
    @test.call(arg)
  end

  def self.by_type(type)
    Detour.config.defined_groups.fetch type.classify, []
  end
end
