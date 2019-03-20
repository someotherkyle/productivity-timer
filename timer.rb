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

def take_input(message = "What are you currently working on?")
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
  puts "Since #{file[:established]}:\n";
  grand_total = 0
  file.each do |key, value|
    unless key == :established
      grand_total += value[:total]
      total_time = value[:total]
      hours = total_time.to_int / 3600
      total_time -= hours * 3600
      minutes = total_time.to_int / 60
      total_time -= minutes * 60
      puts "You've worked on #{key} for #{hours} hours, #{minutes} minutes, and #{total_time.to_int} seconds."
    end
  end
  hours = grand_total.to_int / 3600
  grand_total -= hours * 3600
  minutes = grand_total.to_int / 60
  grand_total -= minutes * 60
  puts "In total, you've worked for #{hours} hours, #{minutes} minutes, and #{grand_total.to_int} seconds."
end

def display_help()
  puts "\nType in the name of the task you're working on and a timer will start."
  puts "Time spent on this activity will be tracked. Feel free to 'pause' at"
  puts "any time. You can also 'review' time spent so far. Type 'exit' to quit"
  puts "the program.\n"
end

def reset_log(file)
  i = 0
  while File.file?("log#{i}.yml")
    i += 1
  end
  File.write("log#{i}.yml", file.to_yaml)
  file = YAML.load_file('template.yml')
  file[:established] = Time.now
  file
end

file = open_file()
display_help()
input = take_input()
current = ""
has_current = false
while input != 'exit'
  if input == current
    puts "You are already working on #{current}."
    input = take_input()
    next
  elsif input == 'pause'
    end_current_task(file, current) if has_current
    puts "If you would like to resume, press enter."
    temp = gets
  elsif input == 'review'
    end_current_task(file, current) if has_current
    has_current = false
    current = input
    review_totals(file)
    input = take_input()
    next
  elsif input == 'help'
    display_help()
    has_current = false
    current = input
    input = take_input()
    next
  elsif input == 'reset'
    file = reset_log(file)
    has_current = false
    current = input
    input = take_input()
    next
  elsif input == 'quit'
    end_current_task(file, current) if has_current
    break
  else
    end_current_task(file, current) if has_current
    current = input
    has_current = true
  end
  begin_new_task(file, current) if has_current
  input = take_input("Let me know what you decide to work on after #{current}.") if has_current
end
end_current_task(file, current) if has_current
File.write('log.yml', file.to_yaml)
