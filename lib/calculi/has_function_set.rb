module Calculi::HasFunctionSet
  extend ActiveSupport::Concern

  include Calculi::Utility
  include Calculi::HasOptionSet
  include Calculi::Attributes

  included do
    set_callback :initialize, :after, :realize_calculi_function_set!

    delegate :function_names, to: :function_set
  end

  def realize_calculi_function_set!
    calculi_function_set.configure(&stored_calculi_function_set_configurator)
  end

  # @!attribute [r] calculi_function_set
  #   @api private
  #   @return [Calculi::FunctionSet]
  def calculi_function_set
    @calculi_function_set ||= Calculi::FunctionSet.new target: self
  end

  def stored_calculi_function_set_configurator
    self.class.stored_calculi_function_set_configurator
  end

  module ClassMethods
    # @!attribute [rw] stored_calculi_function_set_configurator
    attr_accessor :stored_calculi_function_set_configurator

    # @api private
    def calculi_functions(&configurator)
      @stored_calculi_function_set_configurator = configurator if block_given?
    end


    # @api private
    def calculi_function_set
      @calculi_function_set ||= Calculi::FunctionSet.new target: self
    end
  end
end
