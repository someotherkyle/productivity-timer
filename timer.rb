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

def main()
  file = open_file()
  input = take_input("What are you currently working on?")
  current = nil
  while input != 'exit'
    if current == nil
      current = input
    else
      file[current][:ended] = Time.now
      file[current][:total] = file[current][:ended] - file[current][:started]
      file[current].keep_if {|key, value| key == :total}
      current = input
    end
    if file.key?(input)
      file[input][:started] = Time.now
    else
      file[input] = {}
      file[input][:started] = Time.now
    end
    input = take_input("Let me know what you work on after #{input}.")
  end
  binding.pry
end

main

