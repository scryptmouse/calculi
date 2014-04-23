module Calculi::HasOptionSet
  extend ActiveSupport::Concern

  included do
    #delegate :option_set, to: :class
  end

  def option_set
    self.class.option_set
  end

  private
  # @param [Hash] options
  # @return [void]
  def process_options!(options = {})
    option_set.process!(self, options)
  end

  module ClassMethods
    def option_set
      @option_set ||= Calculi::OptionSet.new
    end

    def option!(name, default_value = Calculi::OptionSet::REQUIRED, &default_proc)
      option_set[name] = block_given? ? default_proc : default_value
    end

    def options!(*names)
      names = names.flatten

      names_with_defaults = names.extract_options!

      names_with_defaults.each do |name, default|
        option_set[name] = default
      end

      option_set.add(*names)
    end
  end
end
