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

  context "conversions" do
    should "convert to string" do
      result = ByteBuffer::Result.new [0x46, 0x4F, 0x4F, 0x42, 0x41, 0x52]

      assert_equal "FOOBAR", result
    end

    should "convert to numbers" do
      result = ByteBuffer::Result.new "\242\325$\323\374\260(@"

      assert_equal 4623139617416467874, result
      assert_equal 12.3456789, result
    end
  end

  context "arguments" do
    should "specify bits to read" do
      result = ByteBuffer::Result.new "FOOBAR"

      assert_equal "FOO", result.to_s(:bits => 24)
      assert_equal "FOOB", result.to_s(:bits => 25)

      assert_equal 2, result.to_i(:bits => 2)
      assert_equal 6, result.to_i(:bits => 4)
      assert_equal 70, result.to_i(:bits => 8)
      assert_equal 591, result.to_i(:bits => 10)
      assert_equal 20294, result.to_i(:bits => 16)
      assert_equal 1112493894, result.to_i(:bits => 32)
    end

    should "specify endian to read" do
      result = ByteBuffer::Result.new "FOOBAR!"

      assert_equal "FOOBAR!", result.to_s(:endian => :little_endian)
      assert_equal "FOOBAR!", result.to_s(:endian => :big_endian)

      assert_equal 9379114470297414, result.to_i(:endian => :little_endian)
      assert_equal 19790450202333729, result.to_i(:endian => :big_endian)

      result = ByteBuffer::Result.new "\242\325$\323\374\260(@"

      assert_equal 12.3456789, result.to_f(:endian => :little_endian)
      assert_in_delta -6.93563621441161e-141, result.to_f(:endian => :big_endian), 0.1e-141
    end
  end
end
