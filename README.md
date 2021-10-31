# MiSTer_ScummVM
ScummVM installer and build for the MiSTer platform.

Install instructions:
     
      Run Install_ScummVM.sh
	  Install options can be set in Install_ScummVM.ini 
	  
Install_ScummVM.ini (options)

      INSTALL_DIR="/media/fat/ScummVM"        (Location for ScummVM bin and libs) 
      SCRIPTS_DIR="/media/fat/Scripts"        (Location for ScummVM launcher scripts) 
      DEB_SCUMMVM17="FALSE"                   (TRUE to install Debian ScummVM 1.7)
      BBOND007_SCUMMVM20="FALSE"              (TRUE to install older ScummVM 2.0)
      BBOND007_SCUMMVM21="FALSE"              (TRUE to install ScummVM 2.1)
      BBOND007_SCUMMVM21_UNSTABLE="FALSE"     (TRUE to install ScummVM 2.1 with work-in-progress game engines enabled)
      BBOND007_SCUMMVM22="FALSE"              (TRUE to install ScummVM 2.2)
      BBOND007_SCUMMVM22_UNSTABLE="FALSE"     (TRUE to install ScummVM 2.2 with work-in-progress game engines enabled)
      BBOND007_SCUMMVM23="TRUE"               (TRUE to install ScummVM 2.3)
      BBOND007_SCUMMVM23_UNSTABLE="FALSE"     (TRUE to install ScummVM 2.3 with work-in-progress game engines enabled)
      BBOND007_SCUMMVM25="FALSE"              (TRUE to install ScummVM 2.5)
      BBOND007_SCUMMVM25_UNSTABLE="FALSE"     (TRUE to install ScummVM 2.5 with work-in-progress game engines enabled)
      BBOND007_SCUMMVM250="FALSE"             (TRUE to install ScummVM 2.5.0)
      BBOND007_SCUMMVM250_UNSTABLE="FALSE"    (TRUE to install ScummVM 2.5.0 with work-in-progress game engines enabled)
      ENGINE_DATA="TRUE"                      (TRUE to install engine data files)
      CREATE_DIRS="TRUE"                      (TRUE to create "GAMES" dir)
      DEFAULT_THEME="FALSE"                   (TRUE to install default theme)
      INTERNET_CHECK="https://github.com"     (URL for internet connectivity test)
      VERBOSE_MODE="FALSE"                    (TRUE for verbose mode for debugging issues)
	  
These settings give me the best result on both my monitor (which is a Dell SR2320L - 
(native 1920x1080) connected via VGA and my Elgato HD60s connected via HDMI. 

Suggested settings for full-screen video:

MiSTer.INI:

      [MENU]
      vga_scaler=1
      video_mode=6

ScummVM_2_1_0.sh:

      echo "Setting Video mode..."
      vmode -r 640 480 rgb16

ScummVM/Options:

      Graphics Mode: <default>
      Render Mode: <default>
      [X] Aspect ratio correction
      [ ] Fullscreen mode
	   
ScummVM Links:
       
Homepage --> https://www.scummvm.org/

Github --> https://github.com/scummvm/scummvm

ScummVM supported games --> https://wiki.scummvm.org/index.php/Category:Supported_Games

ScummVM compatibility --> https://www.scummvm.org/compatibility/

Wikipedia --> https://en.wikipedia.org/wiki/ScummVM

ScummVM source used for build:
       
      https://github.com/bbond007/scummvm
      
Scummvm_2_2_0 supported engines:

      SCUMM [all games]
      Access
      ADL
      AGI
      AGOS [all games]
      Beavis and Butthead in Virtual Stupidity
      Blade Runner
      CGE
      CGE2
      Cinematique evo 1
      Magic Composer
      Cinematique evo 2
      Cryo Omni3D games [all games]
      Dragon History
      Drascula: The Vampire Strikes Back
      Dreamweb
      Full Pipe
      UFOs
      Gobli*ns
      Groovie [7th Guest]
      Hyperspace Delivery Boy!
      Hopkins FBI
      Hugo Trilogy
      Illusions Engine
      Kyra [all games]
      Labyrinth of Time
      Lure of the Temptress
      MADE
      MADS
      Mohawk [Living Books] [Myst] [Myst ME] [Riven: The Sequel to Myst]
      Mortevielle
      Neverhood
      Parallaction
      The Journeyman Project: Pegasus Prime
      Plumbers Don't Wear Ties
      The Prince and The Coward
      Flight of the Amazon Queen
      SAGA [ITE] [IHNM]
      SCI [all games]
      The Lost Files of Sherlock Holmes
      Beneath a Steel Sky
      Mission Supernova
      Broken Sword
      Broken Sword II
      Broken Sword 2.5
      Teen Agent
      Tinsel
      Starship Titanic
      3 Skulls of the Toltecs
      Tony Tough and the Night of Roasted Moths
      Toonstruck
      Touche: The Adventures of the Fifth Musketeer
      TsAGE
      Bud Tucker in Double Trouble
      Voyeur
      Wintermute [all games]
      World of Xeen
      Z-Vision

Scummvm_2_2_0_Unstable additional supported (unstable) engines:

      Lord Avalot d'Argent
      Chewy: Esc from F5
      Lost Eden
      Macromedia Director
      Dungeon Master
      Blazing Dragons
      Glk Interactive Fiction games
      The Griffon Legend
      Groovie [Groovie 2 games]
      The Last Express
      Lilliput
      MacVenture
      Mohawk [Where in Time is Carmen Sandiego?]
      Mutation of JB
      Pink Panther
      SAGA [SAGA 2 games]
      Sludge
      Star Trek 25th Anniversary/Judgment Rites
      TestBed: the Testing framework
      Ultima
      WAGE

Videos of ScummVM running on my MiSTer:

Broken Sword II : Shadow of the Templars --> https://youtu.be/cvAkbFFmFOU

Monkey Island III : The Curse of Monkey Island --> https://youtu.be/2H59sGAmZKI

Leisure Suit Larry 7 : Love for Sail! --> https://youtu.be/e6anA4qPgfI

Phantasmagoria : Intro --> https://youtu.be/WpFPYcs-QCI

Phantasmagoria : Chapter I --> https://youtu.be/3PY-_VmXTIg

The 7th Guest (Intro - With remastered audio by James Woodcock) --> https://youtu.be/WZ4AgVrH-uw

Space Quest VI : Roger Wilco in the Spinal Frontier --> https://youtu.be/mee282EkjZQ

Beavis and Butt-Head : Virtual Stupidity --> https://youtu.be/_BjHLZnZt1Q

Discworld (Intro) --> https://youtu.be/l7aNRQE76Ss

Discworld II (Intro) : Missing Presumed...!? --> https://youtu.be/M5P6Ixetwuk

Sam & Max Hit the Road (Intro) - Roland SC88pro Sound --> https://youtu.be/76Qtlfa61Go

Bud Tucker in Double Trouble (Intro) --> https://youtu.be/6OZn4fE4-1k

Spy Fox 1 : Dry Cereal --> https://youtu.be/yPj6nWP4NFc

Spy Fox 2 : Some Assembly Required --> https://youtu.be/2URzAnDQ4F0

Spy Fox 3 : Operation Ozone --> https://youtu.be/2Xlf8LjsO7U

The Feeble Files --> https://youtu.be/yJ-_1XHnOts

Torin's Passage --> https://youtu.be/ZDNT47mpWNU

Urban Runner --> https://youtu.be/STO1Fg3ZLpM

