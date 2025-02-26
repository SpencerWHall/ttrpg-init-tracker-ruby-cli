# Overview
This is a Ruby script that takes in a list of associated string and numeral pairs and displays them in descending order with a cursor that iterates through them one by one until it reaches the bottom and wraps around again. The intended use case is for tracking turn orders in tabletop RPG combat systems.

# Installation
Requires [Ruby](https://www.ruby-lang.org/en/downloads/) to be installed on your machine. Download the source code in this repository and run it by either entering `ruby initiative.rb` into your command prompt of choice or by marking the `initiative.rb` file as executable (e.g. `chmod +x`) and entering `initiative.rb`.

# Usage

### Quick Usage: `initiative.rb [combatant] [initiative] <[...]>`

  Example: `initiative.rb orc 7 ranger 22`

This will produce a basic display with two entries: 

![Screen Shot 2025-02-24 at 5 40 01 PM](https://github.com/user-attachments/assets/fb3eba24-d2d0-4002-ad68-680ded151ee2)




### Advanced Usage: `initiative.rb <[options]> [combatant_attributes] <[combatant_attributes]> <[...]>`

  Advanced Example: `initiative.rb -i 15 -r injured orc 7 -1 -p ranger 22 4 -d=1 -a elf 5 2 -n dwarf 16`

  This will produce a detailed display like so: 

  ![Screen Shot 2025-02-24 at 5 45 04 PM](https://github.com/user-attachments/assets/0d8591bf-01bc-49f7-b7f9-a449d7ae0809)
  
  Due to the specified `-i` value, this initiative round is starting at the first entry at or below initiative value 15. Since `-r` is flagged, once the bottom of the list is reached then each combatant will have its initiative value generated anew using a 20-sided dice roll added to the offset value specified for the combatant (i.e. the second numerical value after the name). Additionally, the ranger will have its initiative value generated at advantage (Please refer to the [SRD 5th Edition](https://www.5esrd.com/using-ability-scores/#:~:text=Advantage) document for an explanation of what this means). Each combatant is displayed in a color that represents its specified relation towards the other combatants: Blue is for players, red is for enemies, green is for allies, and yellow is for neutral combatants. The ranger has been flagged as a player with the `-p` flag, so an indicator now displays which player combatant is next in the turn order.

#### Combatant Attributes(Order of attributes matters): 

  * `-[aenp]`  --  Flag indicating combatant relation ('p' for player character, 'e' for enemy, 'n' for neutral, 'a' for ally). This affects the color of the display entry.
  
  * `[name]`   --   Name of combatant. Must be a non-numeric string. May include whitespace.
  
  * `[init]`   --   Initiative value of combatant. Must be an integer.
  
  * `[offset]`   --  Initiative bonus of combatant. Must be an integer. Only used in --reroll mode. This is a constant value that is added to the dice roll result of the given combatant.
  
  * `-d=[1, -1]` -- Advantage flag. Indicates advantage (positive) or disadvantage (negative). Only used in --reroll mode. Refers to 'Roll Advantage' as per [SRD 5th Edition](https://www.5esrd.com/using-ability-scores/#:~:text=Advantage).

#### Specific Options(Must be specified at the beginning of the argument list):

* `-i [VAL]`,  `--init [VAL]` --  The first round will begin at the integer value specified. This means entry highlighted by the cursor will be the first combatant at or below the specified value.
* `-r` `--reroll`  --  Initiative will be re-rolled for all combatants at the end of each round using a 20-sided dice.

#### Common Options:
* `-h` `--help` -- Displays a message detailing usage. This is also displayed if the program is executed without any parameters.

### Runtime Commands

Input the following keys during the operation of the program to produce the following effects:

  * `x` -- Remove the current combatant from the tracker.
  
  * `i[combatant_attributes]`  -- Add the specified combatant to the tracker according to the 'Combatant Attributes' format specified above.
  
  * `q ` -- Terminate the tracker.
  
  * `h`  --  Display a help message.
  
  * `<any other key>` --  Advance combat by one turn, descending one row in the tracker or wrapping around to the top if at the bottom.
