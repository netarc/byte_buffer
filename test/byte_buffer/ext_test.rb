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
      bb.write_string "BAR"

      assert_equal "FOOBARBAR", bb.buffer
    end
  end

  context "null-string" do
    should "read" do
      bb = ByteBuffer.new("FOOBAR\x00BAR\x00")
      assert_equal "FOOBAR", bb.read_null_string
      assert_equal "BAR", bb.read_null_string
    end

    should "write" do
      bb = ByteBuffer.new
      bb.write_null_string "FOOBAR"
      bb.write_null_string "BAR"

      assert_equal "FOOBAR\x00BAR\x00", bb.buffer
    end
  end

  context "byte and char" do
    should "read" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "F", bb.read_byte
      assert_equal "O", bb.read_char
      assert_equal "O", bb.read_byte
      assert_equal "B", bb.read_char
    end
    should "write" do
    end
  end
end
