require "test_helper"

class ReadTest < Test::Unit::TestCase
  context "read operations" do
    should "read from buffer with no content and end in read mode" do
      bb = ByteBuffer.new
      bb.read

      assert !bb.is_writing?
      assert bb.is_reading?
    end

    should "read from buffer and end in read mode" do
      bb = ByteBuffer.new("FOOBAR")
      bb.read

      assert !bb.is_writing?
      assert bb.is_reading?
    end

    should "read entire remaining buffer" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "FOOBAR", bb.read
      assert_equal "", bb.read
    end

    should "read specified amount of bytes" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "FOO", bb.read(3)
      assert_equal "BAR", bb.read(3)
      assert_equal "", bb.read
    end

    should "read specified amount of bytes and pad if requested" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "FOOBAR\x00\x00", bb.read(8, true)
      assert_equal "\x00\x00", bb.read(2, true)
    end

    should "read one byte value" do
      bb = ByteBuffer.new("FOO\x00\x10")
      assert_equal 70, bb.read_byte_val
      assert_equal 79, bb.read_byte_val
      assert_equal 79, bb.read_byte_val
      assert_equal 0x00, bb.read_byte_val
      assert_equal 0x10, bb.read_byte_val
    end

    should "read one byte value as 0 or nil" do
      bb = ByteBuffer.new("FOO")
      bb.read(3)

      assert_equal nil, bb.read_byte_val
      assert_equal nil, bb.read_byte_val
      assert_equal 0, bb.read_byte_val(false)
      assert_equal 0, bb.read_byte_val(false)
    end
  end
end
