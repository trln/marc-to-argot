# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'marc_to_argot'
require 'util'
require 'marc/record'

RSpec.configure do |c|
  c.include Util::TrajectRunTest
end

class Object
  def stringhash(m)
    Hash[m.map { |k, v| [k.to_s, v] }]
  end
end
