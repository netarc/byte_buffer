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
  end
end
