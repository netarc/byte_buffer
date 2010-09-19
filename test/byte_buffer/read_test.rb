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

    should "reading past the end of buffer should yield error" do
      bb = ByteBuffer.new("FOOBAR")
      assert_equal "FOO", bb.read(3)
      assert_equal "BAR", bb.read(3)
      assert_raises(ByteBuffer::Errors::BufferUnderflow) do
        bb.read(3)
      end
    end

  end
end
