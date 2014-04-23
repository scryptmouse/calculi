module Calculi::Attributes
  extend ActiveSupport::Concern

  include ActiveSupport::Callbacks
  include Calculi::Utility
  include Calculi::HasOptionSet

  included do
    define_callbacks :initialize, :configure
  end

  def initialize(options = {}, &configurator)
    process_options! options

    run_callbacks :initialize

    configure(&configurator) if block_given?
  end

  def configure(&configurator)
    run_callbacks :configure do
      instance_eval(&configurator)
    end
  end

  private
  module ClassMethods
    def calculi_attr(name, type, options = {}, &custom_setter)
      type = Calculi::Attribute.lookup(type)

      include type.new(name, options, &custom_setter)
    end

    def calculi_boolean(name, options = {})
      options = { default: true } if options == true

      calculi_attr name, :boolean, options
    end

    alias_method :calculi_bool, :calculi_boolean

    def calculi_computed(name, &computer_block)
      define_method(name) do
        instance_variable_compute(name, &computer_block)
      end
    end

    def calculi_duration(name, options = {})
      calculi_attr name, :duration, options
    end

    def calculi_integer(name, options = {})
      calculi_attr name, :integer, options
    end

    alias_method :calculi_int, :calculi_integer

    def calculi_procable(name, options = {})
      calculi_attr name, :procable, options
    end

    def calculi_string(name, options = {})
      calculi_attr name, :string, options
    end
  end
end
