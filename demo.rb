require 'lib/vdr'

con = Vdr::Connection.new('localhost',2001)
vdr = Vdr::Vdr.new(con)
puts vdr.disk_usage
