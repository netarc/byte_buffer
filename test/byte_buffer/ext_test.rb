require "test_helper"

class ExtTest < Test::Unit::TestCase
  context "bit" do
    should "read" do
      bb = ByteBuffer.new("\x05")
      assert_equal 0, bb.read_bit
      assert_equal 0, bb.read_bit
      assert_equal 0, bb.read_bit
      assert_equal 0, bb.read_bit
      assert_equal 0, bb.read_bit
      assert_equal 1, bb.read_bit
      assert_equal 0, bb.read_bit
      assert_equal 1, bb.read_bit
    end

    should "write" do
      bb = ByteBuffer.new
      bb.write_bits 8, 0x05

      assert_equal "\x05", bb.buffer
      assert_equal 1, bb.size

      bb = ByteBuffer.new
      bb.write_bits 1, 0
      bb.write_bits 1, 0
      bb.write_bits 1, 0
      bb.write_bits 1, 0
      bb.write_bits 1, 0
      bb.write_bits 1, 1
      bb.write_bits 1, 0
      bb.write_bits 1, 1

      assert_equal "\x05", bb.buffer
      assert_equal 1, bb.size
    end
  end

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

  context "uint8 and int8" do
    should "read" do
      bb = ByteBuffer.new("FOO\xFF\xFE\xFD")
      assert_equal 70, bb.read_uint8
      assert_equal 79, bb.read_int8
      assert_equal 79, bb.read_uint8
      assert_equal 255, bb.read_uint8
      assert_equal -2, bb.read_int8
      assert_equal 253, bb.read_uint8
    end
    should "write" do
      bb = ByteBuffer.new
      bb.write_uint8 "F"
      bb.write_int8 "O"
      bb.write_uint8 "O"
      bb.write_uint8 255
      bb.write_int8 -2
      bb.write_uint8 253

      assert_equal "FOO\xFF\xFE\xFD", bb.buffer
    end
  end

  context "uint16 and int16" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal 20294, bb.read_uint16
      assert_equal 8527, bb.read_uint16
      assert_equal 65279, bb.read_uint16
      assert_equal 64765, bb.read_uint16
      bb.rewind!
      assert_equal 20294, bb.read_int16
      assert_equal 8527, bb.read_int16
      assert_equal -257, bb.read_int16
      assert_equal -771, bb.read_int16
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_uint16 "FO"
      bb.write_uint16 "O!"
      bb.write_uint16 65279
      bb.write_uint16 64765
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_int16 "FO"
      bb.write_int16 "O!"
      bb.write_int16 -257
      bb.write_int16 -771
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end

  context "uint32 and int32" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal 558845766, bb.read_uint32
      assert_equal 4244504319, bb.read_uint32
      bb.rewind!
      assert_equal 558845766, bb.read_int32
      assert_equal -50462977, bb.read_int32
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_uint32 "FOO!"
      bb.write_uint32 4244504319
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_int32 "FOO!"
      bb.write_int32 -50462977
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end

  context "uint64 and int64" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal 18230007238394597190, bb.read_uint64
      bb.rewind!
      assert_equal -216736835314954426, bb.read_int64
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_uint64 "FOO!\xFF\xFE\xFD\xFC"
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_uint64 18230007238394597190
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_int64 "FOO!\xFF\xFE\xFD\xFC"
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_int64 -216736835314954426
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end

  context "float and double" do
    should "read" do
      bb = ByteBuffer.new("\347\207EA\347\207\305B")
      assert_in_delta 12.3456789, bb.read_float, 0.1e-4
      assert_in_delta 98.7654321, bb.read_float, 0.1e-4

      bb = ByteBuffer.new("\242\325$\323\374\260(@")
      assert_equal 12.3456789, bb.read_double
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_float 12.3456789
      bb.write_float 98.7654321
      assert_equal "\347\207EA\347\207\305B", bb.buffer

      bb.reset!

      bb.write_double 12.3456789
      assert_equal "\242\325$\323\374\260(@", bb.buffer
    end
  end

  context "extension aliasing" do
    should "foobar should be aliased to uint8" do
      ByteBuffer.alias_type :foobar, :uint8

      bb = ByteBuffer.new("\x83")
      assert_equal 131, bb.read_foobar

      bb.reset!
      bb.write_foobar "\321"

      assert_equal "\321", bb.to_s
    end
  end

  context "extension types" do
    should "retreive a list of defined types" do
      assert ByteBuffer.known_types.include?(:uint8)
      assert !ByteBuffer.known_types.include?(:foo)
    end
  end
end
