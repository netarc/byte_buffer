require File.expand_path("../lib/byte_buffer", __FILE__)

Gem::Specification.new do |s|
  s.name          = "byte_buffer"
  s.version       = ByteBuffer::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Joshua Hollenbeck"]
  s.email         = ["josh.hollenbeck@citrusbyte.com"]
  s.homepage      = "http://github.com/netarc/byte_buffer"
  s.summary       = "Ruby Byte Buffer"
  s.description   = "ByteBuffer is a tool for working with reading & writing binary data to a blob."

  s.required_rubygems_version = ">= 1.3.6"


  s.add_development_dependency "rake"
  s.add_development_dependency "contest", ">= 0.1.2"
  s.add_development_dependency "mocha"
  s.add_development_dependency "ruby-debug"

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path  = 'lib'
end

