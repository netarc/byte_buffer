class ByteBuffer
  def ensure_write_mode(reset_bit_byte=true)
    if is_writing?
      reset_bit_byte if reset_bit_byte
    elsif is_reading?
      raise Errors::CannotWriteInReadMode.new
    else
      @mode = :write
    end
  end
  private :ensure_write_mode

  def write(data)
    ensure_write_mode
    @buffer <<= format_data(data)
    @pos = @buffer.length
    self
  end

  def write_bits(bits_towrite, value)
    ensure_write_mode false

    if value.is_a?(Array)
      value.each {|v| write_bits bits_towrite, v }
      return self
    end

    unless value.is_a?(Integer)
      raise Errors::ExpectedIntegerSeries.new(:klass => value.class)
    end

    value = value & ((1 << bits_towrite) - 1)
    bits_left = bits_towrite
    while bits_left > 0
      bits = 8 - @bit_pos
      if @bit_pos == 0
        @bit_byte = 0
      else
      end
      if bits_left >= bits
        rem_bits = 0
        bits_left -= bits
        @bit_pos = 0
      else
        rem_bits = bits - bits_left
        bits_left = 0
        @bit_pos = 8 - rem_bits
      end
      @bit_byte |= ((value >> bits_left) << rem_bits) & 0xFF
      if (rem_bits == 0)
        write @bit_byte
      end
    end
  end

end
