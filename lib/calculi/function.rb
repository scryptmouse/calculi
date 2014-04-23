# A calculated function.
class Calculi::Function
  include Calculi::Base

  # @!attribute [r] memoize
  #   @return [Boolean]
  calculi_bool :memoize

  # @!attribute [r] recursive
  #   @note   currently no effect
  #   @todo   implement trampoline or some pseudostack to recur?
  #   @return [Boolean]
  calculi_bool :recursive

  options! :key, :function_set, memoize: false

  # @param context the object that will actually be _calling_ the function, i.e.
  #   what the value of `self` should be.
  # @param args any arguments to pass to the body of the function
  def call(context, *args)
    fn_caller = Calculi::Caller.new(self, context)

    context.instance_exec(target, fn_caller, args, &body)
  end

  def eql?(other)
    other.is_a?(Calculi::Function) && other.hash == hash
  end

  def hash
    [function_set.hash, key.hash].hash
  end

  def inspect
    "Calculi::Function(:#{key}, :dependencies => #{inspect_dependency_names})"
  end

  def inspect_dependency_names
    mapped = dependency_names.map do |name|
      ":#{name}"
    end.join(', ')

    "[#{mapped}]"
  end

  alias_method :to_s, :inspect

  # @!group DSL methods
  def body(&body_proc)
    if block_given?
      @body = body_proc
    end

    @body
  end

  def name(&name_proc)
    if block_given?
      @name = name_proc
    end

    @name
  end

  def requires(*deps)
    dependency_names.merge deps.flatten.map(&:to_s)
  end
  # @!endgroup

  def realized_name
    @realized_name ||= target.instance_eval(&@name)
  end

  def realized_body
    #@realized_body ||= begin
      #__fn = self

      #->(*args) { __fn.call(self, *args) }
    #end
    instance_variable_compute 'realized_body' do
      __fn = self

      ->(*args) { __fn.call(self, *args) }
    end
  end

  # @!group Attributes
  # @!attribute [r] dependency_names
  #   @api private
  #   @return [Set<String>]
  def dependency_names
    @dependency_names ||= Set.new
  end

  # @!attribute [r] function_set
  #   @return [Calculi::FunctionSet]
  attr_reader :function_set

  # @!attribute [r] key
  attr_reader :key

  # @!attribute [r] target
  #   @return [Class]
  delegate :target, to: :function_set
  # @!endgroup
end
