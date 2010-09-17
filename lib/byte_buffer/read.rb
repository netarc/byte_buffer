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
      ret = @buffer[@pos...@pos+bytes_to_read]
      # Didn't have enough to read? pad it out with zeroes
      while pad_bytes and ret.length < bytes_to_read
        ret <<= '\x00'
      end
      @pos += bytes_to_read
    end
    return ret
  end

end
