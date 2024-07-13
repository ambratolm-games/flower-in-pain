#===============================================================
# ● [VX] ◦ Basic HUD ◦ □
# * Basic HUD that shows HP and SP of first character in party on map
#--------------------------------------------------------------
# ◦ by Woratana [woratana@hotmail.com]
# ◦ Thaiware RPG Maker Community
# ◦ Released on: 26/10/2008
# ◦ Version: 1.0
#--------------------------------------------------------------

class Wor_Basic_HUD < Window_Base
  
  SWITCH_ID = 100 # Switch to show/hide this HUD (Turn switch ON to show HUD)
  
  def initialize
    super(-10,-10,162,72)
    self.opacity = 0
    self.visible = $game_switches[SWITCH_ID]
    refresh
  end

  def refresh
    contents.clear
    if $game_party.members.size > 0 and self.visible
      actor = $game_party.members[0]
      draw_actor_hp_gauge(actor, 25, -10, contents.width - 25)
      self.contents.font.color = normal_color
      # Remove '#' in line below if you want bold text~
      # self.contents.font.bold = true
      self.contents.draw_text(0, -5, contents.width, WLH, 'HEALTH')
      @old_hp = actor.hp
    end
  end

  def update
    self.visible = $game_switches[SWITCH_ID]
    if $game_party.members.size > 0 and self.visible
      actor = $game_party.members[0]
      refresh if @old_hp != actor.hp 
    end
  end
end

class Scene_Map < Scene_Base
  alias wora_scemap_str_basichud start
  alias wora_scemap_upd_basichud update
  alias wora_scemap_ter_basichud terminate
  
  def start
    wora_scemap_str_basichud
    @wbasic_hud = Wor_Basic_HUD.new
  end
  
  def update
    wora_scemap_upd_basichud
    @wbasic_hud.update
  end
  
  def terminate
    @wbasic_hud.dispose
    wora_scemap_ter_basichud
  end
end