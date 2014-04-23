# Raised when a non-recursive function tries to call itself
class Calculi::Recursion < StandardError
  def initialize(fn_name)
    super("Non-recursive `#{fn_name}' tried to call itself")
  end
end
