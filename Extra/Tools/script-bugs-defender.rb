#===============================================================

# ° [VX] Prévention des bugs

# ° Par Blockade

# ° Fait le 17/03/10

# ° Version 1.1

# ° http://rpg-maker-vx.bbactif.com/forum.htm

# _/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# ° Notes de versions

#   ~ Version 1.0

#      - Création du script

#   ~ Version 1.1

#      - Correction d'erreurs de scripts (merci à berka)

#      - Ajout d'un système de log

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# ° Installation

#   - Placez au dessus de main, en dessous de vos autres scripts

#     pour maximiser la compatibilité.

#   - Rajoutez dans "Main" juste avant le end :  

#   ensure 

#   activer_autosave if $! != nil

#   - Selectionnez cette partie : 

#   rescue Errno::ENOENT

#   filename = $!.message.sub("No such file or directory - ", "")

#   print("Unable to find file #{filename}.")

#  Cliquez droit, puis cliquez sur "Passer en commentaire"

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# ° Utilisation

#  Tout se fait automatiquement, mais j'ai intégré des fonctions dans les events. 

#  A l'aide de la commande "Appeler un script" mettez :

#   - autosave_exist?

#       Detecte si un fichier d'autosauvegarde est disponible

#   - make_autosave

#       Fait une autosauvegarde

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# ° Comment ca marche ?

# C'est très simple, le script  fait une sauvegarde du jeu à chaque changement de 

# map. Ensuite il détecte si le jeu renvoie une erreur puis si il y a eu une erreur, il 

# charge la sauvegarde automatique.Pour ceux qui utilisent des points de 

# sauvegarde, vous inquiétez pas, cette sauvegarde n'est PAS accessible avec le

# menu de sauvegarde tel qui soit. De plus dans la version 1.1, un fichier texte

# est crée avec les circonstances du bug.

#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

# ° Configuration

# L'auto sauvegarde est crée pour ne pas être chargée avec le système de

# chargement habituel. Donc même si l'on renomme l'autosauvegarde, ça ne

# marchera pas. Mais pour des raisons de sécurité, vous pouvez définir un mot de

# passe pour éviter le chargement d'une autosauvegarde, alors que le jeu n'a pas

# planté. 

#===============================================================



#===============================================================

# Début du module de configuration Blockade::Prevent_Bug

module Blockade

    module Prevent_Bug
  
      Clef_securite = "135792468"  # Tapez votre clef de sécurité ici
  
      Sauvegarder_afterbattle = false # Si l'autosauvegarde doit se faire après un combat aussi
  
  #===============================================================
  
  # Fin de la configuration Blockade::Prevent_Bug
  
  #===============================================================
  
  
  
   #--------------------------------------------------------------------------
  
    # * Fait une sauvegarde de la partie
  
    #-------------------------------------------------------------------------- 
  
    def make_autosave
  
        file = File.open("Autosave.rvdata", "wb")
  
        characters = []
  
        for actor in $game_party.members
  
          characters.push([actor.character_name, actor.character_index])
  
        end
  
        $game_system.version_id = $data_system.version_id
  
        @last_bgm = RPG::BGM::last
  
        @last_bgs = RPG::BGS::last
  
        Marshal.dump(false,           file) # Décale d'un la lecture de la sauvegarde
  
        Marshal.dump(characters,           file)
  
        Marshal.dump(Graphics.frame_count, file)
  
        Marshal.dump(@last_bgm,            file)
  
        Marshal.dump(@last_bgs,            file)
  
        Marshal.dump($game_system,         file)
  
        Marshal.dump($game_message,        file)
  
        Marshal.dump($game_switches,       file)
  
        Marshal.dump($game_variables,      file)
  
        Marshal.dump($game_self_switches,  file)
  
        Marshal.dump($game_actors,         file)
  
        Marshal.dump($game_party,          file)
  
        Marshal.dump($game_troop,          file)
  
        Marshal.dump($game_map,            file)
  
        Marshal.dump($game_player,         file)
  
        file.close
  
      end
  
      
  
    #--------------------------------------------------------------------------
  
    # * Lis l'autosave
  
    #--------------------------------------------------------------------------
  
    def read_autosave_data
  
        file = File.open("Autosave.rvdata", "rb")
  
        securite           = Marshal.load(file)
  
        characters           = Marshal.load(file)
  
        Graphics.frame_count = Marshal.load(file)
  
        @last_bgm            = Marshal.load(file)
  
        @last_bgs            = Marshal.load(file)
  
        $game_system         = Marshal.load(file)
  
        $game_message        = Marshal.load(file)
  
        $game_switches       = Marshal.load(file)
  
        $game_variables      = Marshal.load(file)
  
        $game_self_switches  = Marshal.load(file)
  
        $game_actors         = Marshal.load(file)
  
        $game_party          = Marshal.load(file)
  
        $game_troop          = Marshal.load(file)
  
        $game_map            = Marshal.load(file)
  
        $game_player         = Marshal.load(file)
  
        if $game_system.version_id != $data_system.version_id
  
          $game_map.setup($game_map.map_id)
  
          $game_player.center($game_player.x, $game_player.y)
  
        end
  
        @nom_map = load_data("Data/MapInfos.rvdata")[$game_map.map_id].name
  
      end
  
    #--------------------------------------------------------------------------
  
    # * Crée un log 
  
    #--------------------------------------------------------------------------  
  
      def create_log
  
        # Initialisation des variables
  
        game_name = $data_system.game_title
  
        file_name = "#{game_name}_log.txt"
  
        liste_members = [] 
  
        event_bug = false
  
        temps = Time.now
  
        $game_party.members.each { |member| 
  
        ajout = member.index == $game_party.members.size - 1 ? "." : ", "
  
        liste_members.push(member.name + " (Niv. #{member.level})" + ajout)}
  
        map_name = load_data("Data/MapInfos.rvdata")[$game_map.map_id].name
  
        if $!.message.include?("No such file or directory -")
  
          filename = $!.message.sub("No such file or directory - ", "")
  
          mesage_erreur = "Le ficher #{filename} n'a pas été trouvé."
  
        end
  
        # Gestion du fichier log 
  
        File.delete(file_name) if FileTest.exist?(file_name) # Effacer l'ancien si un fichier log déjà présent
  
        file = File.open(file_name,"w")
  
        text = ["######################################","# Rapport d'erreur de #{game_name}","######################################", 
  
        "Crée le #{temps.strftime('%c')}","","> Informations techniques :"," Liste des personnages présents : #{liste_members} ",
  
        " Bug produit sur la map '#{map_name}'", "","> Informations avancées :","Scene : #{$scene}",
  
        "Description avancée de l'erreur :",mesage_erreur.nil? ? $! : mesage_erreur,"", "",
  
        "# Généré par le script de Prévention des bug de Blockade - Version 1.1"]
  
        text.each {|line|
  
        file.write(line == $! ? line : line + "\n")}
  
        file.close
  
      end
  
    end
  
  end
  
  # Fin de la configuration Blockade::Prevent_Bug
  
  #===============================================================
  
  
  
    #--------------------------------------------------------------------------
  
    # * Active l'autosave
  
    #--------------------------------------------------------------------------
  
    def activer_autosave
  
      include Blockade::Prevent_Bug
  
      return if $!.to_s.include?("exit")
  
      unless FileTest.exist?("Autosave.rvdata")
  
        print "Attention ! Aucun fichier d'autosave n'a été détecté."
  
        return
  
      end
  
      file_name =  "System_Autosave.rvdata"
  
      file = File.open(file_name,"wb") 
  
      $autosave = true
  
      Marshal.dump($autosave,           file)
  
      Marshal.dump(Clef_securite, file)
  
      file.close
  
      create_log
  
    end
  
    
  
  #==============================================================================
  
  # ** Game_Interpreter
  
  #------------------------------------------------------------------------------
  
  #  Gére les évènements, et les commandes d'évènements 
  
  #==============================================================================
  
  class Game_Interpreter
  
    include Blockade::Prevent_Bug
  
    def autosave_exist?
  
      return FileTest.exist?("Autosave.rvdata")
  
    end
  
  end
  
  
  
  #==============================================================================
  
  # ** Game_Map
  
  #------------------------------------------------------------------------------
  
  #  Cette classe gére le joueur
  
  #==============================================================================
  
  class Game_Player
  
    include Blockade::Prevent_Bug
  
    #--------------------------------------------------------------------------
  
    # * Setup
  
    #--------------------------------------------------------------------------
  
    alias block_perform_transfer perform_transfer
  
    def perform_transfer
  
      block_perform_transfer
  
      make_autosave
  
    end
  
  end
  
  
  
  #==============================================================================
  
  # ** Scene_Title
  
  #------------------------------------------------------------------------------
  
  #  Cette class gère l'affichage de l'écran titre
  
  #==============================================================================
  
  class Scene_Title < Scene_Base
  
  include Blockade::Prevent_Bug
  
    alias start_block start
  
    #--------------------------------------------------------------------------
  
    # * Start processing
  
    #--------------------------------------------------------------------------
  
    def start
  
      unless $BTEST
  
        check_autosave
  
        if $autosave
  
          load_database 
  
          $scene = Scene_Autosave.new
  
        end
  
      end
  
      start_block
  
    end
  
    
  
    #--------------------------------------------------------------------------
  
    # * Regarde si un bug à eu lieu
  
    #--------------------------------------------------------------------------
  
    def check_autosave
  
      file_name =  "System_Autosave.rvdata"
  
      file_exist = FileTest.exist?(file_name)
  
      create_system_autosave unless file_exist
  
      file = File.open(file_name,"rb")
  
      $autosave = Marshal.load(file)
  
      $clef           = Marshal.load(file)
  
      file.close
  
   end
  
   
  
    #--------------------------------------------------------------------------
  
    # * Initialize les données
  
    #--------------------------------------------------------------------------
  
    def create_system_autosave
  
      file = File.open("System_Autosave.rvdata","wb") 
  
      $autosave = false
  
      Marshal.dump($autosave,           file)
  
      Marshal.dump(Clef_securite, file)
  
      file.close
  
    end
  
  end
  
  
  
  #==============================================================================
  
  # ** Scene_Autosave
  
  #------------------------------------------------------------------------------
  
  # Scene qui affiche la fenêtre de chargement de l'autosave
  
  #==============================================================================
  
  class Scene_Autosave < Scene_Base
  
    include Blockade::Prevent_Bug
  
    #--------------------------------------------------------------------------
  
    # * Start
  
    #--------------------------------------------------------------------------  
  
    def start
  
      nom_map = read_autosave_data
  
      @window_explications = Explications_Window.new(0,128,544,160,nom_map)
  
      if $clef != Clef_securite
  
        create_system_autosave
  
      end
  
    end
  
    #--------------------------------------------------------------------------
  
    # * Terminate
  
    #--------------------------------------------------------------------------       
  
    def terminate
  
      @window_explications.dispose
  
    end
  
    
  
    #--------------------------------------------------------------------------
  
    # * Update
  
    #--------------------------------------------------------------------------       
  
    def update
  
      @window_explications.update
  
      if Input.trigger?(Input::C) && $clef == Clef_securite
  
        create_system_autosave
  
        case @window_explications.index
  
          when 0
  
            Sound.play_decision
  
            charger_autosave
  
          when 1
  
            Sound.play_cancel
  
            $scene = Scene_Title.new
  
          end
  
        elsif Input.trigger?(Input::C) && $clef != Clef_securite
  
            Sound.play_cancel
  
            $scene = Scene_Title.new
  
        end
  
      end
  
      
  
  
  
    #--------------------------------------------------------------------------
  
    # * Initialize les données
  
    #--------------------------------------------------------------------------
  
    def create_system_autosave
  
      file = File.open("System_Autosave.rvdata","wb") 
  
      $autosave = false
  
      Marshal.dump($autosave,           file)
  
      Marshal.dump(Clef_securite, file)
  
      file.close
  
    end
  
  
  
     #--------------------------------------------------------------------------
  
    # * Charge l'autosave
  
    #-------------------------------------------------------------------------- 
  
    def charger_autosave
  
      $scene = Scene_Map.new
  
      RPG::BGM.fade(1500)
  
      Graphics.fadeout(60)
  
      Graphics.wait(40)
  
      @last_bgm.play
  
      @last_bgs.play
  
    end
  
  end
  
  
  
  #==============================================================================
  
  # ** Explications_Window
  
  #------------------------------------------------------------------------------
  
  #  La fenêtre de chargement de l'autosave
  
  #==============================================================================
  
  class Explications_Window < Window_Selectable
  
    include Blockade::Prevent_Bug
  
    #--------------------------------------------------------------------------
  
    # * Initialize
  
    #--------------------------------------------------------------------------
  
    def initialize(x,y,h,w,nom_map)
  
      super(x,y,h,w)
  
      @column_max = 2
  
      @item_max = 2
  
      @index = 0
  
      @nom_map = nom_map
  
      if $clef != Clef_securite
  
        refresh_acces_refuse
  
      else
  
        refresh_acces_autorise
  
      end
  
    end
  
    
  
    #--------------------------------------------------------------------------
  
    # * Affichage des éléments si l'accès est autorisé
  
    #--------------------------------------------------------------------------
  
    def refresh_acces_autorise
  
      self.contents.font.color = system_color
  
      self.contents.draw_text(0, 0, 512, WLH,"#{$data_system.game_title} à rencontré un problème et à du s'arrêter.", 1)
  
      self.contents.font.color = normal_color
  
      self.contents.font.size = 16
  
      text = ["Le système fait des sauvegardes automatiques à intervalles réguliers.",
  
                 "La sauvegarde à été faite sur la map '#{@nom_map}'",
  
                 "Voulez vous charger cette sauvegarde ?"]
  
      y = 24          
  
      text.each { |line|
  
      self.contents.draw_text(0, y, 512, WLH,line,1)
  
      y += WLH}
  
      self.contents.draw_text(0, y, 250, WLH,"Oui",1)
  
      self.contents.draw_text(260, y, 250, WLH,"Non",1)
  
      self.contents.font.size = 20
  
    end
  
    
  
     #--------------------------------------------------------------------------
  
    # * Affichage des éléments si l'accès est refusé
  
    #-------------------------------------------------------------------------- 
  
    def refresh_acces_refuse
  
      self.contents.font.color = system_color
  
      self.contents.draw_text(0, 0, 512, WLH,"#{$data_system.game_title} à rencontré un problème.", 1)
  
      self.contents.font.color = normal_color
  
      self.contents.font.size = 16
  
      text = ["En effet, vous avez essayé de modifier un fichier, pour lancer l'autosauvegarde.",
  
                 "Malheuresement, ceci n'a pas marché, et le fichier d'autosauvegarde",
  
                 "a été remplacé pour éviter les dysfonctionnements.",
  
                 "Appuyez sur entrée pour continuer."]
  
      y = 24          
  
      text.each { |line|
  
      self.contents.draw_text(0, y, 512, WLH,line,1)
  
      y += WLH}
  
      self.contents.font.size = 20
  
    end
  
  
  
    #--------------------------------------------------------------------------
  
    # * Tailles et formes du curseur, selon l'index
  
    #--------------------------------------------------------------------------
  
    def item_rect(index)
  
      return Rect.new(600, 600, 250, WLH) if $clef != Clef_securite
  
      case index
  
      when 0
  
        return Rect.new(0, 96, 250, WLH)
  
      when 1
  
        return Rect.new(260,96, 250,WLH)
  
      end
  
    end
  
    
  
    #--------------------------------------------------------------------------
  
    # * Défini le nombre maximal d'éléments
  
    #--------------------------------------------------------------------------
  
    def page_row_max
  
      return @item_max
  
    end
  
  end
  
  
  
  #==============================================================================
  
  # ** Scene_Battle
  
  #------------------------------------------------------------------------------
  
  # Cette classe gére les combats
  
  #==============================================================================
  
  class Scene_Battle < Scene_Base
  
    include Blockade::Prevent_Bug
  
    #--------------------------------------------------------------------------
  
    # * Après avoir gagné sauvegarde la partie
  
    #--------------------------------------------------------------------------  
  
    alias process_victory_block  process_victory
  
    def process_victory
  
      process_victory_block
  
      make_autosave if Sauvegarder_afterbattle && !$BTEST
  
    end
  
  end