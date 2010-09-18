class ByteBuffer
  def ensure_read_mode
    if is_reading?
      reset_bit_byte
    elsif is_writing?
      raise Errors::CannotReadInWriteMode.new
    else
      @mode = :read
    end
  end
  private :ensure_read_mode

  def read(bytes_to_read=nil, pad_bytes=false)
    ensure_read_mode

    bytes_to_read||= 0
    unless bytes_to_read.is_a?(Integer)
      raise Errors::ExpectedInteger.new(:klass => bytes_to_read.class)
    end

    if bytes_to_read <= 0
      ret = @buffer[@pos..-1]
      @pos = @buffer.length
    else
      ret = @buffer[@pos...@pos+bytes_to_read] || ""
      # Didn't have enough to read? pad it out with zeroes
      while pad_bytes and ret.length < bytes_to_read
        ret <<= "\x00"
      end
      @pos += bytes_to_read
    end
    return ret
  end

  def read_byte_val(allow_nil=true)
    ensure_read_mode

    v = read(1)
    if v.empty?
      return nil if allow_nil
      return 0
    end
    return v[0]
  end

  def read_bits(bits_toread)
    ensure_read_mode

    bits_left = bits_toread
    result = 0
    while bits_left > 0
      bits = 8 - @bit_pos
      # If bit_pos is zero then we need to read another byte and no mask
      if @bit_pos == 0
        @bit_byte = read_byte_val(false)
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
