require "test_helper"

class ResultTest < Test::Unit::TestCase
  context "initialization" do
    should "return empty values" do
      result = ByteBuffer::Result.new ""

      assert_equal "", result
      assert_equal 0, result
      assert_equal 0.0, result
    end
  end

end
