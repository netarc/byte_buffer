require "test_helper"

class ExtTest < Test::Unit::TestCase
  context "string extension" do
    should "read" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "FOOBAR", bb.read_string
    end

    should "write" do
      bb = ByteBuffer.new
      bb.write_string "FOOBAR"

      assert_equal "FOOBAR", bb.buffer
    end
  end

  context "null-string" do
    should "read" do
      bb = ByteBuffer.new("FOOBAR\x00BAR")
      assert_equal "FOOBAR", bb.read_null_string
    end

    should "write" do
      bb = ByteBuffer.new
      bb.write_null_string "FOOBAR"

      assert_equal "FOOBAR\x00", bb.buffer
    end
  end
end
