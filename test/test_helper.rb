# Add this folder to the load path for "test_helper"
$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'byte_buffer'
require 'contest'
require 'mocha'

# Try to load ruby debug since its useful if it is available.
# But not a big deal if its not available (probably on a non-MRI
# platform)
begin
  require 'ruby-debug'
rescue LoadError
end

class Test::Unit::TestCase
  def fixtures_path
    ByteBuffer.source_root.join("test", "fixtures")
  end
end
