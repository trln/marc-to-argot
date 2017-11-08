require 'spec_helper'

describe Traject::Macros::ArgotSemantics do

  class Context
    include Traject::Macros::ArgotSemantics
  end
  
  before(:each) do
    @context = Context.new
  end



  it 'Hierarchicalizes arrays properly' do
    data = %w[first second third]
    expected = ['first', 'first:second', 'first:second:third']
    expect(@context.array_to_hierarchy_facet(data)).to eq(expected)
  end

  it 'Hierarchicalizes multiple arrays properly' do
    data = [
        %w[first second third],
        %w[first second fourth ]
    ]
    expected = [ 'first', 'first:second', 'first:second:third', 'first:second:fourth' ].sort!
    result = @context.arrays_to_hierarchy(data).sort!
    expect(result).to eq(expected)
  end

  it 'Splits array of delimited strings and hierarchicalizes' do
    data = ['a:b:c', 'a:b:d']
    expected = ['a', 'a:b', 'a:b:c', 'a:b:d']
    result = @context.explode_hierarchical_strings(data).sort!
    expect(result).to eq(expected)
  end
end


