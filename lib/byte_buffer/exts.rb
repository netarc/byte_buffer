class ByteBuffer

  class Type
    attr_accessor :read, :write
    def initialize(type_name, &block)
      @type_name = type_name
      block.call(self)
    end
  end

  @@types = {}

  class << self
    def known_types
      @types.keys
    end

    def define_type(type_name, &block)
      raise TypeAlreadyDefined.new(:type_name => type_name) if @@types[type_name]
      @@types[type_name] = Type.new(type_name, &block)
      define_type_methods(type_name)
    end

    def define_type_methods(type_name)
      define_method(:"read_#{type_name}") do |*args|
        read_method = @@types[type_name].read
        read_method.call(self, *args)
      end
      define_method(:"write_#{type_name}") do |*args|
        write_method = @@types[type_name].write
        write_method.call(self, *args)
      end
    end
    private :define_type_methods
  end

  # string is greedy, it will eat the whole buffer on a read
  define_type :string do |type|
    type.read = Proc.new do |byte_buffer, args|
      byte_buffer.read.to_s
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data
    end
  end

  # null-terminated string
  define_type :null_string do |type|
    type.read = Proc.new do |byte_buffer, args|
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

  # 1-Byte Numbers
  define_type :byte do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(1).to_i
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0] : [data.to_i].pack('C')
    end
  end
  define_type :char do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(1).to_i(:signed => true)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data.is_a?(String) ? data[0] : [data.to_i].pack('c')
    end
  end

  # 2-Byte Numbers
  define_type :word do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(2).to_i
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('S')
    end
  end
  define_type :short do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(2).to_i(:signed => true)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('s')
    end
  end

  # 4-Byte Numbers
  define_type :dword do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(4).to_i
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('L')
    end
  end
  define_type :long do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(4).to_i(:signed => true)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('l')
    end
  end

  # 8-Byte Numbers
  define_type :dwordlong do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(8).to_i
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('Q')
    end
  end
  define_type :longlong do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(8).to_i(:signed => true)
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_i].pack('q')
    end
  end

  # Floats
  define_type :float do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(4).to_f
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_f].pack('e')
    end
  end
  define_type :double do |type|
    type.read = Proc.new do |byte_bufer, args|
      byte_buffer.read(8).to_f
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write [data.to_f].pack('E')
    end
  end
end
