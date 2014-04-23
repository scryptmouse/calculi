class Calculi::Attribute::String < Calculi::Attribute::Abstract
  def default_setter
    ->(o) { o.to_s }
  end
end
