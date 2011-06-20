require 'time'

module Timeclock
  class Clock
    class << self
    def home_directory
      running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
    end

    def put_log_string(contents)
      File.open(log_file, "w").write(contents)
    end

    def get_log_string
      File.open(log_file, 'r') { |f| f.read }
    end

    def log_file
      "#{home_directory}/.timeclock"
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def clock_in
      string = get_log_string
      array = string.split("\n")
      if !array.empty?
        if array.last.include? "in"
          puts "You are already clocked in"
          exit(1)
        end
      end
      print "what are you working on: "
      job = STDIN.gets.strip
      array << "in #{job} #{Time.now}"
      put_log_string array.join("\n")
      puts "clocking in at #{Time.now}"
    end

    def clock_out
      string = get_log_string
      array = string.split("\n")
      if array.last.include? "out"
        puts "You are already clocked out"
        exit(1)
      end
      array << "out #{Time.now}"
      put_log_string array.join("\n")
      puts "clocking out at #{Time.now.to_s}"
    end

    def collect
      string = get_log_string
      array = string.split("\n")
      rtn = []
      until array.empty?
        clock_in = array.shift
        clock_out = array.shift
        if clock_in && clock_out
          in_array = clock_in.split(" ")
          out_array = clock_out.split(" ")
          in_time = Time.parse("#{in_array[2]} #{in_array[3]} #{in_array[4]}")
          out_time = Time.parse("#{out_array[2]} #{out_array[3]} #{out_array[4]}")
          hash = {}
          hash[:hours] = (out_time - in_time) / 3600 #convert to hours
          hash[:clock_in] = in_time.to_s 
          hash[:clock_out] = out_time.to_s
          hash[:project] = in_array[1]
          rtn << hash
        else
          puts "You do not have an even number of clock in's and out's"
        end
      end
      rtn
    end

    def send
      puts collect
      print "who should I send this to: "
      to = STDIN.gets.strip
      begin
        require 'pony'
        require 'erb'

        Pony.mail(
          :to => to, 
          :from => "Lyon <lyon@delorum.com>", 
          :subject => "Time card", 
          :content_type => 'text/html',
          :html_body => ERB.new(File.new("templates/email.html.erb").read).result(binding),
          :body => "Make it read html so you can see the awesomeness that is my timecard"
          )
        puts "Time card has been sent to #{to}."
      rescue Exception => e
        puts "Time card not sent because pony is dumb."
      end

    end

    def check_file
      `touch #{log_file}` unless File.exist? log_file
    end

    def clear
      `rm #{log_file}`
      check_file
    end


    end
  end
end

