class Calculi::Attribute::Duration < Calculi::Attribute::Abstract
  def default_setter
    ->(new_duration) do
      case new_duration
      when Integer        then new_duration
      when Numeric        then new_duration.to_i
      when :hour, :hourly then 1.hour
      when :day,  :daily  then 1.day
      when :week, :weekly then 1.week
      when Proc           then coerce(value.call)
      else 1.day
      end
    end
  end
end

