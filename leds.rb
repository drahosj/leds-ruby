require 'unimidi'
require 'serialport'

class SerialAdaptor
  def initialize
  end
  def write
  end
end

class MidiAdaptor
  attr_reader :note_array
  def initialize
    @input = UniMIDI::Input.gets
    @note_array = []
    108.times do
      @note_array << :off
    end
  end
  
  def update_array
    inputs = @input.gets.each 
    inputs.each do |message|
      puts message
      data = message[:data]
      puts data.length
      i = 0
      begin
        if data[i] == 144 
          @note_array[data[i+1]] = :on
          i = i + 3
        elsif data[i] == 128
          @note_array[data[i+1]] = :off
          i = i + 2
        else
          i = i + 1
        end
      end until i >= data.length
    end
  end
end

def print_array
  out = ""
  @ma.note_array.each do |n|
    out << '0' if n == :on
    out << 'X' if n == :off
  end
  puts out
end

def main

  sa = SerialAdaptor.new
  @ma = MidiAdaptor.new

  loop do
    @ma.update_array
    print_array
  end
end

main
