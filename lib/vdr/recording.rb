module Vdr
  Recording = Struct.new("Recording", :connection, :id, :title, :date, :watched, :channel, :subtitle, :description)
  class Recording
    def subtitle
      if @subtitle.nil?
        load_details
      end
      @subtitle
    end

    def description
      if @description.nil?
        load_details
      end
      @description
    end

    private
    def load_details
      response = self.connection.send_command "LSTR #{self.id}"
      response.each do |line|
        case line[0..4]
        when "215-S"
          @subtitle = line[6..line.length].strip
        when "215-D"
          @description = line[6..line.length].strip
        end
      end
    end
  end
end