require "test_helper"

class WriteTest < Test::Unit::TestCase
  context "write operations" do
    should "write to buffer with no content and end in write mode" do
      bb = ByteBuffer.new
      bb.write "foobar"

      assert bb.is_writing?
      assert !bb.is_reading?
      assert_equal "foobar", bb.buffer
    end

    should "write to buffer with content and end in write mode" do
      bb = ByteBuffer.new("foo")
      bb.write "bar"

      assert bb.is_writing?
      assert !bb.is_reading?
      assert_equal "foobar", bb.buffer
    end

    should "write to buffer with bits and end in write mode" do
      bb = ByteBuffer.new

      bb.write_bits 8, 70
      assert "F", bb.buffer

      bb.write_bits 8, 0x4F
      bb.write_bits 8, 79
      assert "FOO", bb.buffer

      bb.write_bits 8, [66, 0x41, 82]
      assert "FOOBAR", bb.buffer

      bb.write_bits 4, 1
      bb.write_bits 4, 1
      assert "FOOBAR!", bb.buffer

      bb.write_bits 4, [1, 1]
      assert "FOOBAR!!", bb.buffer

      assert bb.is_writing?
      assert !bb.is_reading?
    end

    should "throw an error when writing bits with a value other than an integer" do
      bb = ByteBuffer.new
      assert_raises(ByteBuffer::Errors::ExpectedIntegerSeries) do
        bb.write_bits 8, 'a'
      end

      assert_raises(ByteBuffer::Errors::ExpectedIntegerSeries) do
        bb.write_bits 8, nil
      end

      assert_raises(ByteBuffer::Errors::ExpectedIntegerSeries) do
        bb.write_bits 8, :key
      end

      assert_raises(ByteBuffer::Errors::ExpectedIntegerSeries) do
        bb.write_bits 8, 10.0
      end
    end

    should "throw an error when attempting to write to a read locked buffer" do
      bb = ByteBuffer.new("FOOBAR")
      bb.read
      assert_raises(ByteBuffer::Errors::CannotWriteInReadMode) do
        bb.write "FOO"
      end
    end

    should "can write to buffer after reading and then rewinding" do
      bb = ByteBuffer.new("FOOBAR")

      bb.read
      assert_raises(ByteBuffer::Errors::CannotWriteInReadMode) do
        bb.write "FOO"
      end

      bb.rewind!
      assert_nothing_raised do
        bb.write "FOO"
      end
    end
  end
end
