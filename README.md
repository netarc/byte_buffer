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
      define_type :dbl_null_string do |type|
        type.read = Proc.new do |byte_buffer, args|
          result = ""
          cnt = 0
          while true
            byte = byte_buffer.read(1).to_s
            if byte == "\x00"
              cnt+=1
              break if cnt >= 2
              next
            end
            result <<= byte
          end
          result
        end
        type.write = Proc.new do |byte_buffer, data|
          byte_buffer.write data
          byte_buffer.write 0x00
          byte_buffer.write 0x00
        end
      end
    end

Then just use elsewhere:

    bb = ByteBuffer.new(...)
    bb.write_dbl_null_string "FOOBAR"
    ...
    my_custom_title = bb.read_dbl_null_string

## Out of the box types:

    string
    null_string

    byte
    char

    word
    short

    dword
    long

    dwordlong
    longlong

    float
    double
