module Vdr
  class Vdr

    VALID_KEYS = %w{Up Down Menu Ok Back Left Right Red Green Yellow Blue 0 1 2 3 4 5 6 7 8 9 Play Pause Stop Record FastFwd FastRew Power Channel+ Channel- Volume+ Volume- Mute Audio Schedule Channels Timers Recordings Setup Commands User1 User2 User3 User4 User5 User6 User7 User8 User9}

    def initialize(connection)
      @connection = connection
    end

    def osd_message(message)
      response = @connection.send_command "MESG #{message}"
      check_response(response)
    end

    def disk_usage
      response = @connection.send_command "STAT disk"
      response_array = response.split
      response_array.delete("250")
      response_array
    end

    def press_key(key)
      valid_key = VALID_KEYS.find do |validkey| validkey == key end
        raise ArgumentError if valid_key.nil?
        response = @connection.send_command "HITK #{key}"
        check_response(response)
      end

      def valid_keys
        VALID_KEYS
      end

      def channels
        if @channels.nil?
          reload_channels
        end
        @channels
      end

      def reload_channels
        response = @connection.send_command "LSTC"
        check_response(response)
        response = response.gsub(/^250-/,'')
        @channels = Array.new
        response.each do |line|
          id, channel_info_string = seperate_id_rest_of_line(line)
          channel_info_array = channel_info_string.split(":")
          name, bouquet = channel_info_array[0].split(";")
          @channels << Channel.new(id.to_i, name, bouquet,
          channel_info_array[1].to_i, # frequency
          channel_info_array[2],      # parameter
          channel_info_array[3],      # source
          channel_info_array[4].to_i, # symbol_rate
          channel_info_array[5],      # video pid
          channel_info_array[6],      # audio pid
          channel_info_array[7],      # teletext id
          channel_info_array[8],      # conditional_access_id
          channel_info_array[9],      # service_id
          channel_info_array[10],     # network_id
          channel_info_array[11],     # transport_stream_id
          channel_info_array[12]      # radio_id
          )
        end
        @channels
      end

      def recordings
        response = @connection.send_command "LSTR"
        check_response(response)
        response = response.gsub(/^250-/,'')
        @recordings = Array.new
        response.each do |line|
          id, recording_string = seperate_id_rest_of_line(line)
          time = recording_string[0..13]
          watched = recording_string[14] == 42 ? false : true
          title = recording_string[16..recording_string.length]
          date = DateTime.strptime("#{time}", fmt='%d.%m.%y %H:%M')
          @recordings << Recording.new(@connection, id, title, date, watched)
        end
        @recordings
      end

      private
      def seperate_id_rest_of_line(line)
        line.strip!
        id = line.match(/^[0-9]* /)[0]
        rest_of_line = line.gsub!(/^[0-9]* /,'')
        [id.to_i, rest_of_line]
      end

      def check_response(response)
        if response.match(/^250/).nil?
          raise ArgumentError
        end
      end
    end
  end