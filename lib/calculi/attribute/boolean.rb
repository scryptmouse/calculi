class Calculi::Attribute::Boolean < Calculi::Attribute::Abstract
  # @!attribute [r] default
  #   Default value for the attribute
  #   @return [Boolean]

  # @override
  def default_setter
    ->(o) { !!o }
  end

  private
  def define_predicate!
    alias_method predicate_name, getter_name
  end
end
