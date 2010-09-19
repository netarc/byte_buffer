require "test_helper"

class BaseTest < Test::Unit::TestCase
  context "initialization" do
    should "have an empty buffer when passing no data" do
      bb = ByteBuffer.new
      assert_equal "", bb.buffer
      assert_equal 0, bb.size
    end

    should "default endian should be equal to class default upon instantiation" do
      bb = ByteBuffer.new
      assert_equal ByteBuffer.endian, bb.endian
      ByteBuffer.endian = :big_endian
      assert_equal :little_endian, bb.endian
      ByteBuffer.endian = :little_endian
    end

    should "not be in read or write mode" do
      bb = ByteBuffer.new
      assert !bb.is_reading?, "should not be in read mode"
      assert !bb.is_writing?, "should not be in write mode"
    end
  end

  context "instantiation with data types" do
    should "accept a data type of String" do
      bb = ByteBuffer.new("foobar")
      assert_equal "foobar", bb.buffer
    end

    should "accept a data type of Array" do
      bb = ByteBuffer.new([1, :key, "foobar", [1, 2], 'bar'])
      assert_equal "1keyfoobar12bar", bb.buffer
    end

    should "accept a data type of Nil" do
      bb = ByteBuffer.new(nil)
      assert_equal "", bb.buffer
    end

    should "accept a data type of File" do
      file = File.open(File.expand_path('foobar.txt', fixtures_path))
      bb = ByteBuffer.new(file)
      file.close
      assert_equal "this is some file with foobar data in it.\nanother foobar line.\n", bb.buffer
    end

    should "throw an error with an unkonw data type" do
      klass = Class.new
      assert_raises(ByteBuffer::Errors::UnsupportedData) do
        ByteBuffer.new(klass)
      end
    end
  end

  context "operations" do
    should "empty buffer and reset mode on hard reset" do
      bb = ByteBuffer.new("some foobar data")
      bb.reset!

      assert "", bb.buffer
      assert !bb.is_reading?, "should not be in read mode"
      assert !bb.is_writing?, "should not be in write mode"
    end

    should "be at end of buffer on a fast-forward" do
      bb = ByteBuffer.new("some foobar data")

      assert 0, bb.pos
      bb.fastforward!
      assert bb.size, bb.pos
    end
  end
end
