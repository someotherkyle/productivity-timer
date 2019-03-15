# A lightweight CLI productivty timer
# Author: Kyle Smith
# Version: 1.0
# A user should be able to type in an activity and a timer will begin 
# tracking time spent on that activity.
# 'exit' will exit 'pause' will temporarily stop the timer and 'review'
# will output time tracked

#!/usr/bin/env ruby
require 'yaml'
require 'pry'

def take_input(message) #Look into default arg here
  puts message
  input = gets.chomp
end

def open_file()
  if File.file?('log.yml')
    file = YAML.load_file('log.yml')
  else
    file = YAML.load_file('template.yml')
    file[:established] = Time.now
  end
  file
end

def end_current_task(file, current)
  file[current][:ended] = Time.now
  if file[current].has_key?(:total)
    file[current][:total] = file[current][:total] + (file[current][:ended] - file[current][:started])
  else
    file[current][:total] = file[current][:ended] - file[current][:started]
  end
  file[current].keep_if {|key, value| key == :total}
end

def begin_new_task(file, current)
  if file.key?(current)
    file[current][:started] = Time.now
  else
    file[current] = {}
    file[current][:started] = Time.now
  end
end

def review_totals(file)
  file.each do |key, value|
    unless key == :established
      binding.pry
      total_time = value[:total]
      hours = total_time.to_int / 3600
      total_time -= hours * 3600
      minutes = total_time.to_int / 60
      total_time -= minutes * 60
      puts "You've worked on #{key} for #{hours} hours, #{minutes} minutes, and #{total_time} seconds."
    end
  end
end

file = open_file()
input = take_input("What are you currently working on?")
current = nil
while input != 'exit'
  if current == nil
    current = input
  elsif input == current
    puts "You are already working on #{current}."
  end

  if input == 'pause'
    end_current_task(file, current) unless current == 'review' || current == 'pause'
    puts "If you would like to resume, press enter."
    temp = gets
  elsif input == 'review'
    end_current_task(file, current) unless current == 'review' || current == 'pause'
    review_totals(file)
    next
  else
    end_current_task(file, current) unless current == 'review' || current == 'pause'
    current = input
  end
  begin_new_task(file, current) unless current == 'review' || current == 'pause'
  input = take_input("Let me know what you work on after #{current}.")
end
end_current_task(file, current) unless current == 'review' || current == 'pause'
File.write('log.yml', file.to_yaml)
