require 'i18n'

class ByteBuffer
  autoload :Errors,        'byte_buffer/errors'

  attr_accessor :endian

  @@types = {}
  @@endian = :little_endian

  class << self
    def known_types
      @@types.keys
    end

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
    if data.is_a?(String)
      @buffer = data
    elsif data.is_a?(File)
      @buffer = data.read
    elsif data.is_a?(ByteBuffer)
      @buffer = data.buffer
    elsif data.is_a?(Array)
      @buffer = data.join
    elsif data.is_a?(NilClass)
      @buffer = ""
    else
      raise Errors::UnsupportedData.new(:klass => data.class)
    end

    @endian = @@endian
    @pos = 0
    @bit_pos = 0
    @mode = nil
  end

  def buffer
    @buffer
  end
  alias :to_s buffer

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

  def reset!
    @buffer = ""
    @mode = nil
  end
end

# Default I18n to load the en locale
I18n.load_path << File.expand_path("../../templates/locales/en.yml", __FILE__)

require 'byte_buffer/read'
require 'byte_buffer/write'
require 'byte_buffer/version'
