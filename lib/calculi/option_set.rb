class Calculi::OptionSet
  include Calculi::Utility
  include Enumerable

  REQUIRED = Object.new

  # @!attribute [r] defined_options
  #   @api    private
  #   @return [Hash]
  attr_reader :defined_options

  delegate :each, to: :sorted_options

  def initialize
    @defined_options = {}
  end

  def add(*option_names)
    option_names.flatten.each do |name|
      define name
    end

    return self
  end

  def <<(option_name)
    define option_name

    return self
  end

  def define(option_name, default_value = REQUIRED)
    defined_options.store(option_name, default_value)

    clear_sorted!

    return self
  end

  alias_method :[]=, :define

  def fetch(option_name)
    defined_options.fetch option_name
  end

  alias_method :[], :fetch

  def process!(context, options)
    options = options.with_indifferent_access

    each do |name, default_value|
      value = options.fetch name do
        eval_or_value default_value, context: context
      end

      raise ArgumentError, "Missing required attribute: #{name}" if required?(value)

      set_attribute(name, value, context: context)
    end
  end

  private
  def clear_sorted!
    @sorted_options = nil
  end

  def required?(value)
    REQUIRED === value
  end

  def sorted_options
    @sorted_options ||= Hash[sort_options]
  end

  def sort_options
    defined_options.sort do |(k1, v1), (k2, v2)|
      r1 = required? v1
      r2 = required? v2

      if r1 ^ r2
        r1 ? -1 : 1
      else
        k1 <=> k2
      end
    end
  end
end
