require 'io/console'

# Reads keypresses from the user including 2 and 3 escape character sequences.
module KeyPress
  def get_key_press
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  # oringal case statement from:
  # http://www.alecjacobson.com/weblog/?p=75
  def process_key_press
    c = @key_press

    case c
    when " "
      cursor.select!
    when "\t"
      #do nothing for now.
    when "\e" #Escape Key
      cursor.deselect!
    when "\e[A"
      cursor.move(:up)
    when "\e[B"
      cursor.move(:down)
    when "\e[C"
      cursor.move(:right)
    when "\e[D"
      cursor.move(:left)
    when "\u0003"
      #Leave me alone. I quit.
      puts "CONTROL-C"
      exit 0
    when /^.$/
      #???
      # puts "SINGLE CHAR HIT: #{c.inspect}"
    else
      #Nothing.
      # puts "SOMETHING ELSE: #{c.inspect}"
    end
  end
end
