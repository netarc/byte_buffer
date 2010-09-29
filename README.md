# ByteBuffer

* Source: [http://github.com/netarc/byte_buffer](http://github.com/netarc/byte_buffer)

ByteBuffer is a tool for reading & writing data to a blob.  With the ability to easily extend it to write/read custom data types.

## Quick Start

Simply:

    gem install byte_buffer

Then just begin working with the Buffer with something like:

    bb = ByteBuffer.new
    bb.write_null_string "FOOBAR"
    bb.write_word 23

    file.write bb.buffer

Or maybe for reading data from our output above:

    bb = ByteBuffer.new(file.read)
    title = bb.read_null_string     # => FOOBAR
    count = bb.read_word            # => 23

## Extendable

Want to have your own custom types? No problem! Simple as including in your project at startup:

    class Bytebuffer
      define_type :quad_byte do |type|
        type.read = Proc.new do |byte_buffer, args|
          result = ""
          result << byte_buffer.read_byte
          result << byte_buffer.read_byte
          result << byte_buffer.read_byte
          result << byte_buffer.read_byte
          result
        end
        type.write = Proc.new do |byte_buffer, data|
          byte_buffer.write_byte data[0]
          byte_buffer.write_byte data[1]
          byte_buffer.write_byte data[2]
          byte_buffer.write_byte data[3]
        end
      end
    end

Then just use elsewhere:

    bb = ByteBuffer.new(...)
    bb.write_quad_byte "FOO!"
    bb.write_quad_byte "BAR!"
    ...
    bb.read_quad_byte => "FOO!"
    bb.read_quad_byte => "BAR!"

## Out of the box types:

    misc
      string
      null_string

    8bit
      uint8 => byte
      int8 => char

    16bit
      uint16 => word
      int16 => short

    32bit
      uint32 => dword
      int32 => long
      float

    64bit
      uint64 => dwordlong
      int64 => longlong
      double
