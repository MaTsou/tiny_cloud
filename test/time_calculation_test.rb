require_relative 'test_helper'
require_relative '../lib/tiny_cloud/time_calculation'

class MyTest
  include TinyCloud::TimeCalculation
  def convert( hash )
    convert_in_seconds( hash )
  end
end

describe TinyCloud::TimeCalculation do
  before do
    @my_test = MyTest.new
    @h = 3600
    @d = 24 * @h
    @w = 7 * @d
  end

  it "correctly convert hours" do
    _( @my_test.convert( { hours: 1 } ) ).must_equal @h
    _( @my_test.convert( { hours: 3 } ) ).must_equal 3 * @h
  end

  it "correctly convert days" do
    _( @my_test.convert( { days: 1 } ) ).must_equal @d
    _( @my_test.convert( { days: 3 } ) ).must_equal 3 * @d
  end

  it "correctly convert weeks" do
    _( @my_test.convert( { weeks: 1 } ) ).must_equal @w
    _( @my_test.convert( { weeks: 3 } ) ).must_equal 3 * @w
  end

  it "correctly convert mixed delays" do
    _( @my_test.convert( { days: 1, hours: 1 } ) ).must_equal @d + @h
    _( @my_test.convert( { days: 2, hours: 3 } ) ).must_equal 2 * @d + 3 * @h
    _( @my_test.convert( { weeks: 2, hours: 3 } ) ).must_equal 2 * @w + 3 * @h
  end
end
