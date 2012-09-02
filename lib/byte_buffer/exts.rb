class ByteBuffer

  class Type
    attr_accessor :read, :write, :conversion
    def initialize(type_name, &block)
      @type_name = type_name
      @read = nil
      @write = nil
      @conversion = :to_i
      block.call(self)
    end
  end

  @@types = {}

  class << self
    def known_types
      @@types.keys
    end

    def get_type(type_name)
      @@types[type_name]
    end

    def define_type(type_name, &block)
      raise TypeAlreadyDefined.new(:type_name => type_name) if @@types[type_name]
      @@types[type_name] = Type.new(type_name, &block)
      define_type_methods(type_name)
    end

    def alias_type(type_name, aliased_type)
      if type_name.is_a?(Array)
        type_name.each {|t| alias_type t, aliased_type}
        return
      end
      raise TypeAlreadyDefined.new(:type_name => type_name) if @@types[type_name]
      @@types[type_name] = @@types[aliased_type]
      define_type_methods(type_name)
    end

    def define_type_methods(type_name)
      define_method(:"read_#{type_name}") do |*args|
        options = args[0] || {}
        read_method = @@types[type_name].read
        conversion = @@types[type_name].conversion
        result = read_method.call(self, options)
        result = result.send(conversion) unless conversion.nil?
        result
      end
      define_method(:"write_#{type_name}") do |*args|
        write_method = @@types[type_name].write
        write_method.call(self, *args)
      end
    end
    private :define_type_methods
  end

  define_type :bit do |type|
    type.conversion = nil
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read_bits(1)
    end
    type.write = Proc.new do |byte_buffer, data|
      data = !!data.to_s.match(/(true|t|yes|y|1)$/i) ? 1 : 0
      byte_buffer.write_bits(1, data)
    end
  end

  # string is greedy, it will eat the whole buffer on a read
  define_type :string do |type|
    type.conversion = :to_s
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data
    end
  end

  # null-terminated string
  define_type :null_string do |type|
    type.conversion = nil
    type.read = Proc.new do |byte_buffer, opts|
      result = ""
      while true
        byte = byte_buffer.read(1).to_s
        break if byte.empty? || byte == "\x00"
        result <<= byte
      end
      result
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data
      byte_buffer.write 0x00
    end
  end

  define_type :uint8 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(1, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0] : [data.to_i].pack('C')
    end
  end
  alias_type :byte, :uint8

  define_type :int8 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(1, opts.merge({:signed => true}))
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0] : [data.to_i].pack('c')
    end
  end
  alias_type :char, :int8


  define_type :uint16 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(2, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..1] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('n') : [data.to_i].pack('v'))
    end
  end
  alias_type :word, :uint16

  define_type :int16 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(2, opts.merge({:signed => true}))
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..1] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('n') : [data.to_i].pack('v'))
    end
  end
  alias_type :short, :int16


  define_type :uint32 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(4, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..3] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('N') : [data.to_i].pack('V'))
    end
  end
  alias_type :dword, :uint32

  define_type :int32 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(4, opts.merge({:signed => true}))
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..3] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('N') : [data.to_i].pack('V'))
    end
  end
  alias_type :long, :int32


  define_type :uint64 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(8, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..7] : [data.to_i].pack('Q')
    end
  end
  alias_type :dwordlong, :uint64

  define_type :int64 do |type|
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(8, opts.merge({:signed => true}))
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..7] : [data.to_i].pack('q')
    end
  end
  alias_type :longlong, :int64


  define_type :float do |type|
    type.conversion = :to_f
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(4, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..3] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('g') : [data.to_i].pack('e'))
    end
  end
  define_type :double do |type|
    type.conversion = :to_f
    type.read = Proc.new do |byte_buffer, opts|
      byte_buffer.read(8, opts)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0..7] : (byte_buffer.endian == :big_endian ? [data.to_i].pack('E') : [data.to_i].pack('G'))
    end
  end
end
