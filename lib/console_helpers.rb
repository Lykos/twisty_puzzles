require 'io/console'

module ConsoleHelpers

  def camel_to_snake(string)
    string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
  end

  def espeak_processes
    @espeak_processes ||= {}
  end

  def espeak_process(language)
    espeak_processes[language] ||=
      IO.popen("espeak -v #{language} -s 160", 'w+')
  end
    
  def puts_and_say(stuff, language='de')
    puts stuff
    espeak_process(language).puts(stuff)
  end

  # Exits in the case of character q.
  def wait_for_any_key
    char = STDIN.getch
    if char.downcase == 'q'
      puts 'Pressed q. Exiting.'
      exit
    end
    char
  end

end
