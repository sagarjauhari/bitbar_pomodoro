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

POMODORO_TIME = 25 # minutes
TMP_FILE_PATH = "/tmp/bitbar_pomodoro.txt"

# To enable logging, set path of a log file here or as an environment variable
LOG_FILE_PATH = ENV["BITBAR_LOGFILE_PATH"] || "/Users/sagar/bitbar_pomodoro.log"
# If logging is enabled, you can set a daily goal of Pomodoros to complete
# each day. Your daily progress will be shown on the Bitbar dropdown.
DAILY_GOAL = 4

class BitbarPomodoro
  def initialize(options)
    # Default to 'check' action if nothing is provided
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
      if DateTime.now >
        (DateTime.parse(@start_time) + POMODORO_TIME/(24 * 60.0))
        write_to_log_file unless LOG_FILE_PATH.to_s == ""
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
    write_to_tmp_file
    print_started
  end

  def stop
    @file.truncate(0)
    notification_cmd = '\'display notification "Complete!" with title ' +
                       '"Pomodoro" sound name "Tink"\''
    `osascript -e #{notification_cmd}`

    print_ended
  end

  def write_to_tmp_file
    @file.write "#{@start_time},running\n"
  end
  
  def write_to_log_file
    File.open(LOG_FILE_PATH, "a") do |file|
      file << DateTime.now.to_s << "\n"
    end
  end
  
  def print_started
    start_time = DateTime.parse(@start_time).to_time
    percent_complete = (((Time.now - start_time)/60)*(100/POMODORO_TIME)).floor
    puts "🍅  #{percent_complete}%"
    puts "---"
    puts "Pomodoro"
    puts "---"
    puts "►  Started at #{start_time.strftime("%H:%M")}"
    puts "◼  Stop | color=red terminal=false bash=#{__FILE__} param2=--stop "\
      "refresh=true"
    puts progress_text
  end

  def print_ended
    puts "🍅 "
    puts "---"
    puts "Pomodoro"
    puts "---"
    puts "► Start | color=green terminal=false bash=#{__FILE__} param2=--start "\
      "refresh=true"
    puts "◼  Stop"
    puts progress_text
  end

  def progress_text
    unless LOG_FILE_PATH.to_s == ""
      last_poms = IO.readlines(LOG_FILE_PATH) || []
      poms_completed_today = last_poms.select do |time_str|
        DateTime.parse(time_str).to_date == DateTime.now.to_date
      end.count

      puts "---"

      puts "⚫"*poms_completed_today +
           "⚪"*(DAILY_GOAL - poms_completed_today)
    end
  end
end

# Parse arguments: --start, --stop, --check
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
