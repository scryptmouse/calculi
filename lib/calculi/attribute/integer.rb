class Calculi::Attribute::Integer < Calculi::Attribute::Abstract
  def default_setter
    ->(o) { o.try(:to_i) || 0 }
  end
end
