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

  it 'hiearchicalizes multiple arrays properly' do
    data = [
        %w[first second third],
        %w[first second fourth ]
    ]
    expected = [ 'first', 'first:second', 'first:second:third', 'first:second:fourth' ].sort!
    result = @context.arrays_to_hierarchy(data).sort!
    expect(result).to eq(expected)
  end

end


