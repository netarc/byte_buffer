class ByteBuffer
  def ensure_read_mode
    if is_reading?
      reset_bit_byte
    elsif is_writing?
      raise CannotReadInWriteMode
    else
      @mode = :read
    end
  end
  private :ensure_read_mode
end
