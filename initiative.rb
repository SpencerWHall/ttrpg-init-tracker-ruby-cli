#!/usr/bin/env ruby
require 'io/console'
require 'colorize'
class CombatActor
  @@actor_types = [:enemy,:pc,:neutral,:ally]
  @@pc_abbr_map = { #Replace these abbreviations and names with your own party's
                    'gax' => 'Gaxixes',
                    'sin' => 'Sindar',
                    'bry' => 'Bryn',
                    'tal' => 'Taleon',
                    'bae' => 'Baern',
                    #Replace these abbreviations and initiative bonuses with your own party's
                    'gax_i' => 3.0,
                    'sin_i' => 6.0,
                    'bry_i' => 2.0,
                    'tal_i' => 4.0,
                    'bae_i' => 1.0
                  }
  def initialize(argv, reroll = false)
    if argv.first =~ /^-[pena]$/
      char = /^-([pena])/.match(argv.first).captures.first
      argv.slice! 0
      if char == 'p'
          @actor_type = :pc
      elsif char == 'e'
          @actor_type = :enemy
      elsif char == 'n'
          @actor_type = :neutral
      elsif char == 'a'
          @actor_type = :ally
      end
    else
      @actor_type = :enemy
    end
    @reroll = reroll
    name = argv.first.to_s
    if @@pc_abbr_map.keys.include? name.downcase
      @name = @@pc_abbr_map[name.downcase]
      @actor_type = :pc
      @offset = @@pc_abbr_map[name.downcase + '_i']
    else
      @name = name.capitalize
    end
    argv.slice! 0
    while argv.length > 0
      if argv.first =~ /^[\+\-]?[0-9]*\.?[0-9]+/ || argv.first =~ /^-d=-?1/
        break
      else
        @name += ' ' + argv.first
        argv.slice! 0
      end
    end
    if argv.first =~ /^[\+\-]?[0-9]*\.?[0-9]+/
      @initiative = argv.first.to_f
      argv.slice! 0
    end
    if (@reroll && argv.first =~ /^[\+\-]?[0-9]*\.?[0-9]+/)
      @offset = argv.first.to_f
      argv.slice! 0
    end
    if argv.first =~ /^-d=-?1/
      @advantage = argv.first.split('=')[1]
      argv.slice! 0
    end
    self
  end
  def display_string
    init_str = "{" + "#{'%.02f' % [@initiative]}".to_s.rjust(5,"0").white + "}"
    if @actor_type == :enemy
      name_str = @name.red
    elsif @actor_type == :pc
      name_str = @name.light_blue
    elsif @actor_type == :neutral
      name_str = @name.yellow
    elsif @actor_type == :ally
      name_str = @name.light_green
    end
    init_str + " " + name_str
  end
  def actor_type
    @actor_type
  end
  def next
    @next
  end
  def next=(nxt)
    @next = nxt
  end
  def initiative
    @initiative
  end
  def initiative=(init)
    @initiative = init
  end
  def next_pc
    nxt = @next
    while (!nxt.nil? and nxt.actor_type != :pc and nxt != self)
      nxt = nxt.next
    end
    nxt
  end
  def reroll
    if @offset.nil? then @offset = 0 end
    @initiative = Random.rand(19)+1+@offset
    unless @advantage.nil?
      if @advantage == '-1'
        @initiative = [Random.rand(19)+1, Random.rand(19)+1].min + @offset
      else
        @initiative = [Random.rand(19)+1, Random.rand(19)+1].max + @offset
      end
    end
  end
  def set_init(init_str)
    tokens = init_str.split
    if tokens.first =~ /^[\+\-]?[0-9]*\.?[0-9]+/
      @initiative = tokens.first.to_f
      tokens.slice! 0
    end
    if (@reroll && tokens.first =~ /^[\+\-]?[0-9]*\.?[0-9]+/)
      @offset = tokens.first.to_f
      tokens.slice! 0
    end
    if tokens.first =~ /^-d=-?1/
      @advantage = tokens.first.split('=')[1]
      tokens.slice! 0
    else
      @advantage = nil
    end
  end
end

class InitiativeTracker
  def initialize(argv)
    @options = {}
    @optionbanner = "\n" +
       "Quick Usage: initiative.rb [combatant] [initiative] <[...]>\n" +
      "\n" +
      "  Example: initiative.rb orc 7 ranger 22\n" +
      "\n" +
      "Advanced Usage: initiative.rb <[options]> [combatant_attributes] <[combatant_attributes]> <[...]>\n" +
      "\n" +
      "Combatant Attributes: (Order of attributes matters)\n" +
      "  -[aenp]    Flag indicating relation (\'p\' for player character, \'e\' for enemy, \'n\' for neutral, \'a\' for ally)\n" + 
      "  [name]     Name of combatant. Must be a non-numeric string.\n" +
      "  [init]     Initiative value of combatant. Must be a number.\n" +
      "  [offset]   Initiative bonus of combatant. Must be a number. Only used in --reroll mode\n" +
      "  -d=[1, -1] Advantage flag. Indicates advantage (positive) or disadvantage (negative). Only used in --reroll mode\n" +
      "\n" +
      "  Advanced Example: initiative.rb -i 15 -r injured orc 7 -1 -p ranger 22 4 -d=1 -a elf 5 2 -n dwarf 16\n" +
      "\n" +
      "Specific options:\n" +
      "    -i  --init [VAL]    The first round will begin at the initiative value specified\n" +
      "    -r  --reroll        Initiative will be re-rolled for all combatants at the end of each round\n" +
      "\n" +
      "Common options:\n" +
      "    -h  --help          Show this message\n" +
      "\n" +
      "Runtime Commands:\n" +
      "  x                          Remove the current combatant from the tracker\n" +
      "  i[combatant_attributes]    Add the specified combatant to the tracker\n" +
      "  q                          Terminate the tracker\n" +
      "  h                          Show this message\n" +
      "  <any other key>            Advance combat by one turn\n"
    while ['-h','--help','help','-i','--init','-r','--reroll'].include? argv.first
      if argv.first == '-h' or argv.first == '--help' or argv.first == 'help'
        puts @optionbanner
        exit
      end
      if argv.first == '-i' or argv.first == '--init'
        argv.slice! 0
        @options[:init] = argv.first.to_f
        argv.slice! 0
      end
      if argv.first == '-r' or argv.first == '--reroll'
        argv.slice! 0
        @options[:reroll] = true
      end
    end
    @arr = []
    while (argv.length > 0)
      if (@options[:reroll])
        @arr << CombatActor.new(argv,true)
      else
        @arr << CombatActor.new(argv)
      end
    end
    make_init
  end
  def run
    unless @arr.empty?
      run_loop
      system "clear"
      puts "Combat complete"
      exit
    end
    puts @optionbanner
    exit
  end
  def make_init
    initiative = @arr.map {|actor| actor.initiative}
    while (initiative.uniq.length != initiative.length)
      for i in 0..initiative.length do
        if initiative.count(initiative[i]) > 1
          actors = @arr.find_all { |actor| actor.initiative == initiative[i]} 
          pcs = actors.find_all{|actor| actor.actor_type == :pc}
          if pcs.length > 0
            actors = pcs
          end
          i_val = initiative[i].to_f
          i_val += 0.01
          initiative[i] = i_val
          actors.first.initiative = i_val
        end
      end
    end 
    @arr.sort_by! { |actor| actor.initiative  } 
    @arr.each_with_index { |actor, index|
      if (actor == @arr.first)
        actor.next = @arr.last
      else
        actor.next = @arr[index - 1]
      end
    }
  end
  def run_loop
    current_actor = @arr.last
    if !@options[:init].nil?
      actors_remaining = @arr.select{|actor| actor.initiative <= @options[:init]}
      if (actors_remaining.length > 0)
        current_actor = actors_remaining.last
      end
    end
    while (@arr.length > 0)
      system "clear"
      puts "Current turn: " + current_actor.display_string
      puts "Next turn: " + current_actor.next.display_string
      if current_actor.next.actor_type != :pc && @arr.map{|actor| actor.actor_type}.include?(:pc)
        puts "Player on deck: " + current_actor.next_pc.display_string
      else
        puts ""
      end
      @arr.reverse.each { |actor| 
        if actor == current_actor 
          puts actor.display_string.on_light_black
        else
          puts actor.display_string
        end }
      input = STDIN.getch
      if input == 'x'
        next_actor = current_actor.next
        @arr.delete(current_actor)
        make_init
        current_actor = next_actor
        next
      end
      if input == 'd'
        input = STDIN.gets
        current_actor.set_init(input)
        make_init
        next
      end
      if input == 'q'
        system "clear"
        puts "Combat complete"
        exit
      end
      if input == 'i'
        input = STDIN.gets
        if (@options[:reroll])
          @arr << CombatActor.new(input.split,true)
        else
          @arr << CombatActor.new(input.split)
        end
        make_init
      end
      if input == 'h'
        system "clear"
        puts @optionbanner
        puts "(Press any key to return)"
        STDIN.getch
      end
      if (!@options[:reroll].nil? && @arr.find_index(current_actor) < @arr.find_index(current_actor.next))
        @arr.each {|actor| actor.reroll}
        make_init
        current_actor = @arr.first
      end
      current_actor = current_actor.next 
    end
  end
end
InitiativeTracker.new(ARGV).run
