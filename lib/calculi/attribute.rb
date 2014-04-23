module Calculi::Attribute
  class << self
    def lookup(type)
      if valid_type?(type)
        type
      elsif type.kind_of?(String) || type.kind_of?(Symbol)
        type_from_string type
      else
        raise "Unknown attribute type: #{type}"
      end
    end

    def valid_type?(type_klass)
      type_klass.kind_of?(Module) && type < Calculi::Attribute::Abstract
    end

    def type_from_string(type_name)
      type_name = type_name.to_s.classify.demodulize

      "Calculi::Attribute::#{type_name}".constantize
    end
  end
end
