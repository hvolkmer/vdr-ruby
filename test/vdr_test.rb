require 'test/unit'
require 'rubygems'
require 'mocha'
require 'stubba'
require 'socket'
require File.dirname(__FILE__) + '/../lib/vdr'

class VdrTest < Test::Unit::TestCase
  
  def setup
    @connection = Vdr::Connection.new
    @vdr = Vdr::Vdr.new @connection
  end
  
  def test_osd_message
    @connection.expects(:send_command).with("MESG Message").returns("250 Message queued")
    @vdr.osd_message "Message"
  end
  
  def test_osd_message_not_successfull
    @connection.expects(:send_command).with("MESG Message").returns("554 Transaction failed")
    assert_raise ArgumentError do
      @vdr.osd_message "Message"
    end    
  end
  
  def test_disk_usage
    @connection.expects(:send_command).with("STAT disk").returns("250 70228MB 18040MB 74%")
    assert_equal ["70228MB","18040MB","74%"], @vdr.disk_usage
  end
  
  def test_keypress
    @vdr.valid_keys.each do |key|
      @connection.expects(:send_command).with("HITK #{key}").returns("250 Key \"Ok\" accepted")
      @vdr.press_key key
    end
  end
  
  def test_keypress_unknown_key       
    assert_raise ArgumentError do
      @vdr.press_key "UnknownKey"
    end
  end
  
  def test_channels
    @connection.expects(:send_command).with("LSTC").returns(channels_response)
    channels = @vdr.channels
    ard = channels[0]
    assert_equal 1, ard.id
    assert_equal "Das Erste", ard.name
    assert_equal "ARD", ard.bouquet
    assert_equal 11836, ard.frequency
    assert_equal "hC34", ard.parameter
    assert_equal "S19.2E", ard.source
    assert_equal 27500, ard.symbol_rate
    assert_equal "101", ard.video_pid
    assert_equal "102=deu;106=deu", ard.audio_pid
    assert_equal "104", ard.teletext_pid
    assert_equal "0", ard.conditional_access_id
    assert_equal "28106", ard.service_id
    assert_equal "1", ard.network_id
    assert_equal "1101", ard.transport_stream_id
    assert_equal "0", ard.radio_id    
    zdf = channels[1]
    assert_equal 2, zdf.id
    assert_equal "ZDFvision", zdf.bouquet
    assert_equal "ZDF", zdf.name
  end
  
  def test_channel_caching_and_reloading
    @connection.expects(:send_command).with("LSTC").returns(channels_response).times(2)
    loaded_channels = @vdr.channels
    cached_channels = @vdr.channels
    assert_same loaded_channels, cached_channels
    reloaded_channels = @vdr.reload_channels
    assert_not_same loaded_channels, reloaded_channels
  end
  
  def test_recordings
    @connection.expects(:send_command).with("LSTR").returns(recordings_response)
    recordings = @vdr.recordings
    first_recording = recordings.first
    assert_equal 1, first_recording.id
    assert_equal "2006-11-27T20:15:00Z", first_recording.date.to_s
    assert_equal "Der Fahnder", first_recording.title
    assert !first_recording.watched
    watched_recording = recordings[2]
    assert_equal 3, watched_recording.id
    assert_equal "2006-12-01T21:15:00Z", watched_recording.date.to_s
    assert_equal "SOKO Leipzig", watched_recording.title
    assert watched_recording.watched    
  end
  
  def test_recording_details
    recording_detail =<<-DETAIL
215-C S19.2E-1-1101-28106
215-T Der Fahnder
215-S Girlfriends
215-D Wells wird von der jungen Streunerin Manuela beklaut.
215-X 1 01 deu 4:3
215-X 2 03 deu stereo
215-X 2 05 deu Dolby   
DETAIL
    @connection.expects(:send_command).with("LSTR").returns(recordings_response)
    @connection.expects(:send_command).with("LSTR 1").returns(recording_detail)
    recordings = @vdr.recordings
    first_recording = recordings.first
    assert_equal "Girlfriends", first_recording.subtitle
    assert_equal "Wells wird von der jungen Streunerin Manuela beklaut.", first_recording.description
  end
  
  private
  
  def recordings_response
  <<-RECORDINGS
250-1 27.11.06 20:15* Der Fahnder
250-2 25.11.06 00:00* Commissario Laurenti - Gib jedem seinen eigenen Tod
250-3 01.12.06 21:15  SOKO Leipzig
250-4 17.11.06 21:15* SOKO Leipzig
RECORDINGS
  end
  
  def channels_response
  <<-CHANNELS
250-1 Das Erste;ARD:11836:hC34:S19.2E:27500:101:102=deu;106=deu:104:0:28106:1:1101:0
250-2 ZDF;ZDFvision:11953:hC34:S19.2E:27500:110:120=deu,121=2ch;125=dd:130:0:28006:1:1079:0
250-3 RTL Television,RTL;RTL World:12187:hC34:S19.2E:27500:163:104=deu;106=deu:105:0:12003:1:1089:0
250-4 SAT.1;ProSiebenSat.1:12480:vC34:S19.2E:27500:1791:1792=deu;1795=deu:34:0:46:133:33:0
250-5 ProSieben;ProSiebenSat.1:12480:vC34:S19.2E:27500:255:256=deu;257=deu:32:0:898:133:33:0
250-6 RTL2;RTL World:12187:hC34:S19.2E:27500:166:128=deu:68:0:12020:1:1089:0
250-7 VOX;RTL World:12187:hC34:S19.2E:27500:167:136=deu:71:0:12060:1:1089:0
250-8 9Live;BetaDigital:12480:vC34:S19.2E:27500:767:768=deu:35:0:897:133:33:0
250-9 KABEL1;ProSiebenSat.1:12480:vC34:S19.2E:27500:511:512=deu:33:0:899:133:33:0
250-10 Bayerisches FS;ARD:11836:hC34:S19.2E:27500:201:202=deu:204:0:28107:1:1101:0
250-11 Doppelpunkt|Test;DoppelpuktTest:11836:hC34:S19.2E:27500:201:202=deu:204:0:28107:1:1101:0
CHANNELS
  end
  
end
