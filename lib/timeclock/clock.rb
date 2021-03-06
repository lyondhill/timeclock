require 'time'

module Timeclock
  class Clock
    
    @template = "<pre>
    Hay. This is the best formatting I can do.. I'm just a meager programmer..
    <% dl = daily_log %>
    <% total = dl.delete(:total)%>
    <% dl.each do |key, value| %>
    on <%= key.to_s %> I got <%= value[:total] %> hours
    	<% value[:log].each do |ele| %>
    		<%= ele.to_s %>
    	<%end%>
    <%end%>
    For a total of <%= total %> hours

    Thank you!
    </pre>"
    
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

    def put_email_string(contents)
      File.open(email_file, "w").write(contents)      
    end

    def get_email_string
      File.open(email_file, 'r') { |f| f.read }
    end

    def email_file
      "#{home_directory}/.email"
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

    def automate_clock_in
      string = get_log_string
      array = string.split("\n")
      if !array.empty?
        if array.last.include? "in"
          exit(1)
        end
      end
      array << "in del11009 #{Time.now}"
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

    def automate_clock_out
      string = get_log_string
      array = string.split("\n")
      if array.last.include? "out"
        exit(1)
      end
      array << "out #{Time.now}"
      put_log_string array.join("\n")
      puts "clocking out at #{Time.now.to_s}"
    end

    def total
      total = 0.0
      collect.each {|value|total += value[:hours]}
        total
    end

    def daily_log
      collection = collect
      new_hash = {}
      time_array = []
      collection.each do |element|
        day = Time.parse(element[:clock_in]).day
        if new_hash[day]
          new_hash[day][:total] += element[:hours]
          new_hash[day][:log] << {:in => element[:clock_in], :out => element[:clock_out]}
        else
          new_hash[day] = {}
          new_hash[day][:total] = element[:hours]
          new_hash[day][:log] = [{:in => element[:clock_in], :out => element[:clock_out]}]
        end
      end
      new_hash[:total] = total
      new_hash
    end

    def collect
      string = get_log_string
      array = string.split("\n")
      rtn = []
      if array.size.even?
        until array.empty?
          clock_in = array.shift
          clock_out = array.shift
          in_array = clock_in.split(" ")
          out_array = clock_out.split(" ")
          in_time = Time.parse("#{in_array[2]} #{in_array[3]} #{in_array[4]}")
          out_time = Time.parse("#{out_array[1]} #{out_array[2]} #{out_array[3]}")
          hash = {}
          hash[:hours] = (out_time - in_time) / 3600 #convert to hours
          hash[:clock_in] = in_time.ctime 
          hash[:clock_out] = out_time.ctime
          hash[:project] = in_array[1]
          rtn << hash
        end
      else
        puts "You do not have an even number of clock in's and out's"
        exit(1)
      end
      rtn
    end

    def send
      puts collect
      print "who should I send this to: "
      to = STDIN.gets.strip
      print "what email should I send it from: "
      from = STDIN.gets.strip
      
      # begin
        require 'pony'
        require 'erb'

        Pony.mail(
          :to           => to, 
          :from         => from, 
          :subject      => "Time card", 
          :content_type => 'text/html',
          :domain       => "localhost.localdomain",
          :html_body    => ERB.new(@template).result(binding),
          :body         => "You are reading this because your email client sux and cant interperate html... fix it."
          )
        puts "Time card has been sent to #{to}."
      # rescue Exception => e
      #   puts "Time card not sent because pony is dumb."
      # end

    end

    def setup_automate
      puts `whenever -w config/schedule.rb`
    end

    def unsetup_automate
      puts `whenever -c config/schedule.rb`
    end

    def automate
      if `ps aux | grep Adium | grep -v grep`.split("\n").size > 0
        puts "AUTOMATE CLOCK IN"
        automate_clock_in
      else
        puts "AUTOMATE CLOCK OUT"
        automate_clock_out
      end
    end

    def clay
      require 'erb'
      ERB.new(@template).result(binding)
    end

    def email
      string = get_email_string
      array = string.split("\n")
    end

    def check_email
      `touch #{email_file}` unless File.exist? email_file
    end

    def check_file
      `touch #{log_file}` unless File.exist? log_file
    end

    def clear
      print "Are you sure you want delete your existing log? (yes/no): "
      if STDIN.gets.strip == 'yes'
        `rm #{log_file}`
        check_file
      end
    end


    end
  end
end

