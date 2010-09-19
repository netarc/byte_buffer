class ByteBuffer
  def ensure_read_mode
    if is_reading?
      reset_bit_byte
    elsif is_writing?
      raise Errors::CannotReadInWriteMode.new
    else
      @mode = :read
      @pos = 0
    end
  end
  private :ensure_read_mode

  def read(bytes_to_read=-1, options=nil)
    ensure_read_mode

    options||={}

    bytes_to_read||= 0
    unless bytes_to_read.is_a?(Integer)
      raise Errors::ExpectedInteger.new(:klass => bytes_to_read.class)
    end

    if bytes_to_read <= 0
      data = @buffer[@pos..-1]
      @pos = @buffer.length
    else
      raise Errors::BufferUnderflow.new(:bytes => bytes_to_read) if @pos+bytes_to_read > self.size
      data = @buffer[@pos...@pos+bytes_to_read]
      @pos += bytes_to_read
    end
    return Result.new data, {:endian => @endian}.merge(options)
  end

  def read_bits(bits_toread)
    ensure_read_mode

    bits_left = bits_toread
    result = 0
    while bits_left > 0
      bits = 8 - @bit_pos
      # If bit_pos is zero then we need to read another byte and no mask
      if @bit_pos == 0
        @bit_byte = read_byte
        mask = nil
      else
        mask = (1 << bits) - 1
      end
      # if we're reading all the bits, then zero it out
      if bits_left >= bits
        rem_bits = 0
        @bit_pos = 0
        bits_left -= bits
      else
        rem_bits = bits - bits_left
        @bit_pos = 8 - rem_bits
        bits_left = 0
      end
      if mask
        result |= ((@bit_byte & mask) >> rem_bits) << bits_left
      else
        result |= (@bit_byte >> rem_bits) << bits_left
      end
    end
    result
  end

end
