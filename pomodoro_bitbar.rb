#!/usr/local/bin/ruby

# <bitbar.title>Bitbar Pomodoro</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Sagar Jauhari</bitbar.author>
# <bitbar.author.github>sagarjauhari</bitbar.author.github>
# <bitbar.desc>A simple pomodoro plugin for Bitbar</bitbar.desc>
# <bitbar.dependencies>ruby</bitbar.dependencies>
require 'optparse'
require 'ostruct'
require 'date'

# Set the bitbar plugin folder here or as an environment variable
BITBAR_PLUGINS_FOLDER = ENV["BITBAR_PLUGINS_FOLDER"] ||
                        "~/bitbar-plugin-folder"

POMODORO_TIME = 25 # minutes
TMP_FILE_PATH = "/tmp/bitbar_pomodoro.txt"

# Uses terminal-notifier by default. Modify it to use something like growl
NOTIFIER='/usr/local/bin/terminal-notifier -title "Pomodoro" -message '

class BitbarPomodoro
  def initialize(options)
    # Default to 'check' action if nothing provided
    action = options.action || "check"

    # Read file
    @file = File.open(
      TMP_FILE_PATH,
      File.exist?(TMP_FILE_PATH) ? "r+" : "w+"
    )

    if !@file
      create_empty_file
      @status = "stopped"
    else
      @start_time, @status = @file.read.strip.split(",")
    end

    send action

    @file.close
  end

  def check
    if @status == "running"
      if DateTime.now > (
        DateTime.parse(@start_time) + POMODORO_TIME/(24 * 60.0)
      )
        stop
      else
        print_started
      end
    else
      print_ended
    end
  end

  def start
    return if @status == "running"
    @status = "running"
    @start_time = DateTime.now.to_s
    write_to_file
    print_started
  end

  def stop
    @file.truncate(0)
    `#{NOTIFIER} Complete!`
    print_ended
  end

  def write_to_file
    puts "writing to file"
    @file.write "#{@start_time},running\n"
  end
  
  def print_started
    start_time = DateTime.parse(@start_time).to_time
    duration = ((Time.now - start_time)/60).floor
    puts "🍅  #{duration}m"
    puts "---"
    puts "Pomodoro"
    puts "---"
    puts "►  Started at #{start_time.strftime("%H:%M")}"
    puts "◼  Stop | color=red terminal=false bash=#{__FILE__} param2=--stop "\
      "refresh=true"
  end

  def print_ended
    puts "🍅 "
    puts "---"
    puts "Pomodoro"
    puts "---"
    puts "► Start | color=green terminal=false bash=#{__FILE__} param2=--start "\
      "refresh=true"
    puts "◼  Stop"
  end
end

# Parse arguments: --start, --stop
options = OpenStruct.new
OptionParser.new do |parser|
  parser.on('-s', '--start', 'Start pomodoro') do
    options.action = "start"
  end

  parser.on('-t', '--stop', 'Stop pomodoro') do
    options.action = "stop"
  end

  parser.on('-p', '--check', 'Check pomodoro') do
    options.action = "check"
  end
end.parse!

BitbarPomodoro.new(options)
