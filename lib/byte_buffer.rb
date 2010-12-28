require 'i18n'
require 'pathname'

class ByteBuffer
  autoload :Errors,        'byte_buffer/errors'
  autoload :Result,        'byte_buffer/result'

  attr_accessor :endian
  attr_reader :pos

  @@endian = :little_endian

  class << self
    def endian=(v)
      @@endian = (v == :little_endian ? :little_endian : :big_endian)
    end

    def endian
      @@endian
    end

    # The source root is the path to the root directory of the ByteBuffer gem.
    def source_root
      @@source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end


  def initialize(data=nil)
    @buffer = format_data(data)
    @endian = @@endian
    @pos = 0
    @bit_pos = 0
    @bit_byte = nil
    @mode = nil
  end

  def format_data(data)
    if data.is_a?(String)
      return data
    elsif data.is_a?(File)
      return data.read
    elsif data.is_a?(ByteBuffer)
      return data.buffer
    elsif data.is_a?(Array)
      return data.join
    elsif data.is_a?(NilClass)
      return ""
    elsif data.is_a?(Fixnum)
      if data <= 255
        return [data].pack('c')
      elsif data <= 65535
        return [data].pack('s')
      elsif data
        return [data].pack('l')
      end
    elsif data.is_a?(Bignum)
      return [data].pack('Q')
    else
      raise Errors::UnsupportedData.new(:klass => data.class)
    end
  end
  private :format_data

  def buffer
    @buffer
  end
  alias :to_s buffer

  def ==(other)
    self.to_s == other
  end

  def size
    @buffer.length
  end
  alias :length size

  def is_writing?
    @mode == :write
  end

  def is_reading?
    @mode == :read
  end

  def rewind!
    reset_bit_byte!
    @pos = 0
    @mode = nil
    self
  end

  def fastforward!
    reset_bit_byte!
    @pos = @buffer.size
    @mode = nil
    self
  end

  def reset!
    rewind!
    @buffer = ""
    self
  end

  # Soft bit byte reset - will NOT write its contents to buffer
  def reset_bit_byte
    @bit_pos = 0
    @bit_byte = 0
  end
  private :reset_bit_byte

  # Hard bit byte reset - WILL write its contents to buffer
  def reset_bit_byte!
    if is_writing? && @bit_pos > 0
      @buffer <<= @bit_byte.chr
      @pos += 1
    end
    reset_bit_byte
  end
  private :reset_bit_byte!

  def step(bytes)
    reset_bit_byte!
    @pos += bytes
    @pos = 0 if @pos < 0
    bytes_over = @pos - @buffer.size
    if bytes_over > 0
      @pos = @buffer.size
      unless is_reading?
        1.upto(bytes_over) { write "\x00" }
      end
    end
  end
end

# Default I18n to load the en locale
I18n.load_path << File.expand_path("../../templates/locales/en.yml", __FILE__)

require 'byte_buffer/exts'
require 'byte_buffer/read'
require 'byte_buffer/write'
require 'byte_buffer/version'
