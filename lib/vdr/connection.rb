module Vdr
  class Connection

    CRLF = "\r\n"

    def initialize(hostname =  "localhost", port = 2001)
      @hostname = hostname
      @port = port
    end

    def send_command(command)
      socket = TCPSocket.new(@hostname, @port)
      socket.send("#{command}\nquit\n",0)
      puts "Line"
      answer  = Array.new
      while (line = socket.gets(CRLF))
        answer << line
      end
      puts answer
      socket.close
      answer.join(CRLF)
      #answer[1..answer.length].join
    end
  end
end