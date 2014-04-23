class Calculi::Attribute::Procable < Calculi::Attribute::Abstract
  def default_setter
    lambda do |o|
      raise TypeError, "#{o.inspect} isn't procable" unless procable? o

      o
    end
  end
end
