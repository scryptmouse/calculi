module Calculi::Utility
  NON_IVAR  = /\A([^@].+)\z/
  NULL      = Object.new

  # @param [#to_s] s what to prefix
  # @return [String] `@s`
  def at_prefixed(s)
    s.to_s.sub NON_IVAR, '@\1'
  end

  # @param [Object] o
  # @return [Proc] f(o) = -> o
  def constantly(o)
    -> { o }
  end

  # @param [#call] thing
  # @return [Boolean] whether the provided `thing` is callable
  def callable?(thing)
    thing.respond_to? :call
  end

  # @param [#to_proc] callable
  # @return
  def eval_or_value(callable, *args)
    options = args.extract_options!

    context = options.fetch :context, self

    if callable.respond_to?(:to_proc)
      args.length.nonzero? ? context.instance_exec(*args, &callable) : context.instance_eval(&callable)
    else
      callable
    end
  end

  def instance_variable_compute(ivar_name, computed_value = NULL, &compute_value)
    ivar_name = at_prefixed ivar_name

    computed_value_given  = computed_value != NULL
    value_computer_given  = block_given?

    if instance_variable_defined? ivar_name
      return instance_variable_get ivar_name
    end

    if computed_value_given ^ value_computer_given
      instance_variable_set ivar_name, eval_or_value(compute_value)
    elsif computed_value_given && value_computer_given
      raise ArgumentError, "Cannot have both computer and computed value"
    else
      raise ArgumentError, "Missing compute_value block or computed_value"
    end
  end

  # @param [#to_proc] thing
  # @return [Boolean] whether the provided `thing` can be converted to a proc
  def procable?(thing)
    thing.respond_to? :to_proc
  end

  def set_attribute(name, value, options = {})
    context = options.fetch :context, self

    setter = "#{name}="

    if context.respond_to? setter
      context.__send__(setter, value)
    else
      context.instance_variable_set at_prefixed(name), value
    end
  end
end
