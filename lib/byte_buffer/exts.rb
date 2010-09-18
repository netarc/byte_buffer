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
      byte_buffer.read
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
        break if byte.empty?
        break if byte == "\x00"
        result <<= byte
      end
      result
    end
    type.write = Proc.new do |byte_buffer, data|
      byte_buffer.write data
      byte_buffer.write 0x00
    end
  end

end
