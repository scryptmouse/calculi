# Typed attributes with defaults.
# @abstract
class Calculi::Attribute::Abstract < Module
  include Calculi::Utility

  # @!attribute [r] default
  #   Default value for the attribute
  #   @return [Boolean]
  attr_reader :default

  # @!attribute [r] ivar_name
  #   Name of the instance variable used to store the attribute's value.
  #   @return [String]
  attr_reader :ivar_name

  # @!attribute [r] name
  #   Name of the attribute
  #   @return [String]
  attr_reader :name

  # @!attribute [r] setter
  #   Setter to use
  #   @return [Proc]
  attr_reader :setter

  NO_DEFAULT  = Object.new

  NO_DEFAULT.instance_eval do
    def to_proc
      -> { nil }
    end
  end

  PASSTHRU    = ->(o) { o }

  def initialize(name, options = {}, &setter)
    @name       = name.to_s

    @ivar_name  = at_prefixed name

    @default    = options.fetch :default, NO_DEFAULT

    @readonly   = !!options.fetch(:readonly, false)

    @setter     = block_given? ? setter : options.fetch(:setter) { default_setter }

    define_attribute_methods!
  end

  # @abstract
  # @return [Proc]
  def default_setter
    PASSTHRU
  end

  def default?
    default != NO_DEFAULT
  end

  def inspect
    "#{self.class}(:name, :default => #{default.inspect})"
  end

  def readonly?
    @readonly
  end

  private
  def default_name
    @default_name ||= :"default_#{name}"
  end

  def getter_name
    @getter_name ||= :"#{name}"
  end

  def predicate_name
    @predicate_name ||= :"#{name}?"
  end

  def setter_name
    @setter_name ||= :"#{name}="
  end

  def define_attribute_methods!
    define_default!
    define_getter!
    define_predicate!
    define_setter! unless readonly?
  end

  def define_default!
    method_body = procable?(default) ? default : constantly(default)

    define_method(default_name, &method_body)
  end

  def define_getter!
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{getter_name}
        defined?(#{ivar_name}) ? #{ivar_name} : (#{ivar_name} = #{default_name})
      end
    RUBY
  end

  def define_predicate!
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{predicate_name}
        !#{getter_name}.nil?
      end
    RUBY
  end

  def define_setter!
    ivar = ivar_name
    cast_value = setter

    define_method setter_name do |new_value|
      instance_variable_set ivar, cast_value.(new_value)
    end
  end
end
