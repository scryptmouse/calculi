# A set that can hold arbitrarily-computed {Calculi::Function}s
# with a dependency graph
class Calculi::FunctionSet < Module
  include Calculi::Base
  include Enumerable
  include TSort

  DEPENDENCIES_NOT_CALCULATED = Object.new

  # @!attribute [r] target
  #   Where the generated functions should be accessible.
  #   @return [Class]
  attr_reader :target

  options! :target

  delegate :each, to: :functions

  set_callback :configure, :after, :define_functions!

  def [](function_key)
    case function_key
    when Calculi::Function
      functions.detect { |fn, deps| fn.eql? function_key }
    when Symbol, String
      function_key = function_key.to_s

      functions.detect { |fn, deps| fn.key.to_s == function_key }
    else
      raise KeyError, "Don't know how to find function with `#{function_key.inspect}'"
    end
  end

  def fetch(fn)
    self[fn].try(:first) or raise KeyError, "Unknown function: #{fn}"
  end

  def functions
    @functions ||= {}
  end

  def function_names
    @function_names ||= OpenStruct.new
  end

  def function(key, options = {}, &function_configurator)
    options.merge! function_set: self, key: key

    new_function = Calculi::Function.new(options, &function_configurator)

    functions[new_function] = DEPENDENCIES_NOT_CALCULATED
  end

  def inspect
    function_hash = functions.each_key.each_with_object({}) do |fn, fn_hsh|
      fn_hsh[fn.key] = fn.inspect_dependency_names
    end

    "Calculi::FunctionSet(#{function_hash.inspect})"
  end

  def tsort_each_node(&block)
    functions.each_key(&block)
  end

  def tsort_each_child(node, &block)
    fetch(node).dependency_names.each do |dependency_name|
      yield fetch(dependency_name)
    end
  end

  def define_functions!
    tsort.each do |fn|
      function_names[fn.key] = fn.realized_name

      redefine_method(fn.realized_name, &fn.realized_body)
    end

    target.send :include, self
  end
end
