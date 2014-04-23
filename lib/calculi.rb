require 'tsort'

require 'active_support'
require 'active_support/callbacks'
require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/numeric/time'

module Calculi
  require 'calculi/version'
  # Your code goes here...
end

require 'calculi/utility'
require 'calculi/recursion'

require 'calculi/attribute'

%w[abstract boolean duration integer procable string].each do |type|
  require "calculi/attribute/#{type}"
end

require 'calculi/option_set'
require 'calculi/has_option_set'

require 'calculi/attributes'

require 'calculi/base'
require 'calculi/caller'
require 'calculi/function'
require 'calculi/function_set'

require 'calculi/has_function_set'
