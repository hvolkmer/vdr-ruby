module Vdr
  Channel = Struct.new("Channel", :id, :name, :bouquet, :frequency, :parameter, :source, :symbol_rate, :video_pid, :audio_pid, :teletext_pid, :conditional_access_id, :service_id, :network_id, :transport_stream_id, :radio_id)
  class Channel

    def delete!
    end

  end
end