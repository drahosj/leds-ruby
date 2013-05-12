require 'unimidi'
require 'serialport'

class SerialAdaptor
  def initialize port
    @port = SerialPort.new port, 115200, 8, 1, SerialPort::NONE
  end

  def write array
    i = 21
    11.times do
      byte = byte = 0
      byte = byte + 1 if array[i] == :on
      i = i + 1
      7.times do
        byte = byte << 1
        byte = byte + 1 if array[i] == :on
        i = i + 1
      end
      @port.putc byte
      printf "%08b", byte
    end
    puts ""
  end

  def shutdown
    @port.close
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
        if data[i] & 144  == 144 #note on
          puts "On"
          j = 1
          loop do 
            if i + j >= data.length or data[i + j] & 128 == 128 #a status byte
              break
            else
              @note_array[data[i+j]] = :on
              j = j + 2
            end
          end
            i = i + j
          i = i + 1
        elsif data[i] & 128  == 128 #note off
          if data.length == 1
            @note_array.each do |note|
              note = :off
            end
          else
            puts "Off"
            @note_array[data[i+1]] = :off
            i = i + 2
          end
        else
          @note_array[data[i]] = :off
          i = i + 1
        end
      end until i >= data.length
    end
  end
end

def print_array
  out = ""
  @ma.note_array.each do |n|
    out << '1' if n == :on
    out << '0' if n == :off
  end
  puts out
end

def main

  sa = SerialAdaptor.new "/dev/ttyACM0"
  @ma = MidiAdaptor.new

  loop do
  #  print_array
    @ma.update_array
    sa.write @ma.note_array
  end
end

at_exit do
  @port.shutdown
end

main
