# VDR ruby client library

## Description

This is meant to be a ruby client library for [VDR](http://www.tvdr.de/).

It is unfinished. Feel free to continue development. See background story.

### Example usage

    require 'lib/vdr'

    con = Vdr::Connection.new('localhost',2001)
    vdr = Vdr::Vdr.new(con)
    puts vdr.disk_usage


## Background story

I started developing this library in 2006. My parents own a VDR based computer for which I wanted to create a web frontend using Rails and this library.

This was my first attempt at Ruby code. I've been doing Java development before (which you can see in the code, really...). When I started working at [imedo](https://github.com/imedo/) in 2007, I didn't take the time to finish this library. It collected dust on my hard drive since then.

I'm putting it up on github so you can develop it further. Or just use it as inspiration.

You can even develop the whole library without access to VDR as I collected example output from all the commands (as of 11/2006). See test directory.

Other than extracting the code to different files and some indentation the code is basically untouched since 2006.

## Licence

MIT. See licence file.

## Code Ideas

class VDR::VDR

  # Actions
  channel+
  channel-
  channel

  press_key

  # Config / Control
  # Channels
  channels # channel iterator
  channels << # add new channel

  screenshot(filename, quality, heigt, width)

  next_timer_date # NEXT

  timers # timer iterator / array
  timers<<  # add timer

  plugin_command # Magic to discover options => Plugin object

  # EPG Data
  clear_epg
  add_epg(epgdata)
  scan

end

class Timer

  attr_accessor :active, :channel, :start_date, :end_date, :priority, :title

end

class Channel
  attr_accessor :name, :frequency, :parameter, :source, :srate, :vpid, :apid, :tpid, :ca, :sid, :nid, :tid, :rid

  delete!

end

class Recording
  play(begin) # PLAY
  delete!
end

class EpgData
end