class Calculi::Caller
  # @!attribute [r] originator
  #   @return [Calculi::Function]
  attr_reader :originator

  # @!attribute [r] context
  #   @return [Object]
  attr_reader :context

  delegate :key, :function_set, :recursive?, to: :originator
  delegate :fetch, to: :function_set

  def initialize(originator, context)
    @originator = originator
    @context    = context
  end

  def call(other_function_key, *args)
    prevent_recursion! other_function_key

    fetch(other_function_key).call(context, *args)
  end

  alias_method :[], :call

  def chain(*other_functions)
    other_functions.reduce(context) do |last_context, other_function_key|
      other_fn = fetch(other_function_key)

      other_fn.call last_context
    end
  end

  private
  def prevent_recursion!(other_function_key)
    if other_function_key == key && !recursive?
      raise Calculi::Recursion, other_function_key
    end
  end
end
