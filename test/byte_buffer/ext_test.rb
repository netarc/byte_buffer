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
      bb = ByteBuffer.new("FOO\xFF\xFE\xFD")
      assert_equal "F", bb.read_byte
      assert_equal "O", bb.read_char
      assert_equal "O", bb.read_byte
      assert_equal 255, bb.read_byte
      assert_equal -2, bb.read_char
      assert_equal 253, bb.read_byte
    end
    should "write" do
      bb = ByteBuffer.new
      bb.write_byte "F"
      bb.write_char "O"
      bb.write_byte "O"
      bb.write_byte 255
      bb.write_char -2
      bb.write_byte 253

      assert_equal "FOO\xFF\xFE\xFD", bb.buffer
    end
  end

  context "word and short" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal "FO", bb.read_word
      assert_equal "O!", bb.read_word
      assert_equal 65279, bb.read_word
      assert_equal 64765, bb.read_word
      bb.rewind!
      assert_equal "FO", bb.read_short
      assert_equal "O!", bb.read_short
      assert_equal -257, bb.read_short
      assert_equal -771, bb.read_short
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_word "FO"
      bb.write_word "O!"
      bb.write_word 65279
      bb.write_word 64765
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_short "FO"
      bb.write_short "O!"
      bb.write_short -257
      bb.write_short -771
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end

  context "dword and long" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal "FOO!", bb.read_dword
      assert_equal 4244504319, bb.read_dword
      bb.rewind!
      assert_equal "FOO!", bb.read_long
      assert_equal -50462977, bb.read_long
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_dword "FOO!"
      bb.write_dword 4244504319
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_long "FOO!"
      bb.write_long -50462977
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end

  context "dwordlong and longlong" do
    should "read" do
      bb = ByteBuffer.new("FOO!\xFF\xFE\xFD\xFC")
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.read_dwordlong
      bb.rewind!
      assert_equal 18230007238394597190, bb.read_dwordlong
      bb.rewind!
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.read_longlong
      bb.rewind!
      assert_equal -216736835314954426, bb.read_longlong
    end
    should "write" do
      bb = ByteBuffer.new

      bb.write_dwordlong "FOO!\xFF\xFE\xFD\xFC"
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_dwordlong 18230007238394597190
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_longlong "FOO!\xFF\xFE\xFD\xFC"
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer

      bb.reset!

      bb.write_longlong -216736835314954426
      assert_equal "FOO!\xFF\xFE\xFD\xFC", bb.buffer
    end
  end
end
