$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'marc_to_argot'
require 'util'
require 'marc/record'

class Object
  def stringhash(m)
    Hash[m.map { |k, v| [k.to_s, v] }]
  end
end
