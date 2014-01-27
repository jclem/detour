module Keepable
  def to_keep
    @to_keep || (!marked_for_destruction? && !new_record?)
  end
end
