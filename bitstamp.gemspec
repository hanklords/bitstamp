require File.expand_path("../lib/bitstamp", __FILE__)

Gem::Specification.new do |s|
  s.summary = "Bitstamp api wrapper"
  s.name = "hanklords-bitstamp"
  s.author = "Maël Clérambault"
  s.email = "mael@clerambault.fr"
   s.homepage = "https://github.com/hanklords/bitstamp"
  s.license = "ISC"
  s.files = %w(lib/bitstamp.rb LICENSE README.md)
  s.version = Bitstamp::VERSION
end
