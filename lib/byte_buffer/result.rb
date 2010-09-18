class ByteBuffer
  class Result
    def initialize(data, *args)
      args||={}
      if data.is_a?(String)
        @data = data.unpack('C*')
      elsif data.is_a?(Array)
        @data = data
      else
        @data = []
      end
    end

    def size
      @data.size
    end
    alias length size

    def empty?
      size == 0
    end

    def to_a(*args)
      @data
    end

    def to_s(*args)
      options = process_args(*args)
      # UNDO endian reverse for strings
      options[:byte_sample].reverse! if options[:endian] == :big_endian
      options[:byte_sample].pack('C*')
    end
    alias inspect to_s

    def to_f(*args)
      return 0.0 if empty?
      options = process_args(*args)

      if options[:bytes_to_sample] % 8 == 0
        m = 'E'
      elsif options[:bytes_to_sample] % 4 == 0
        m = 'e'
      else
        return 0.0
      end

      options[:byte_sample].pack('C*').unpack(m)[0]
    end

    def to_i(*args)
      return 0 if empty?
      options = process_args(*args)

      # Not reading bits individually, so count bytes
      if options[:bits_to_sample] % 8 == 0
        val = 0
        bit_shift = 0
        options[:byte_sample].each do |byte|
          val += byte << bit_shift
          bit_shift += 8
        end

        if options[:signed]
          max_size = 256 ** options[:bytes_to_sample]
          half_size = (max_size * 0.5).to_i - 1
          val -= max_size if val > half_size
          return val
        else
          return val
        end
      # Reading bits?
      else
        bits = options[:byte_sample].pack('C*').unpack('B*')[0].split('').collect {|x| x.to_i}
        bits = bits.reverse[0..(options[:bits_to_sample]-1)]
        val = 0
        bit_index = 0
        bits.each do |bit|
          val += (1 << bit_index) if bit == 1
          bit_index+=1
        end
        return val
      end
    end

    def ==(other)
      if other.is_a?(Result)
        self.to_a == other.to_a
      elsif other.is_a?(String)
        self.to_s == other.to_s
      elsif other.is_a?(Fixnum) || other.is_a?(Bignum)
        self.to_i == other.to_i
      elsif other.is_a?(Float)
        self.to_f == other.to_f
      else
        false
      end
    end

    def process_args(args={})
      options = {
        :bits_to_sample => args[:bits] || (self.size * 8),
        :endian => args[:endian] == :big_endian ? :big_endian : :little_endian,
        :signed => !!args[:signed]
      }
      options[:bytes_to_sample] = (options[:bits_to_sample] / 8.0).ceil
      options[:byte_sample] = @data[0..(options[:bytes_to_sample] - 1)]
      options[:byte_sample].reverse! if options[:endian] == :big_endian
      options
    end
    private :process_args
  end
end
