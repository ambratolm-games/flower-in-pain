#====================================
class HUD < Sprite
#====================================
#Initialization
def initialize(view)
super(view)
#--------------------------------------------------------------
#Create the colors
@ch1 = Color.new(134,0,131)
@ch2 = Color.new(255,53,140)
@cm1 = Color.new(0,0,0)
@cm2 = Color.new(0,0,0)
@back = Color.new(0,0,0)
@back2 = Color.new(0,0,0)
#--------------------------------------------------------------
#Create the Bitmap
self.bitmap = Bitmap.new(200,200)
self.bitmap.font.name = "Footlight MT Light"
self.bitmap.font.size = 16
self.z = 300
update
end
#--------------------------------------------------------------
#Actualize
def update
super
#--------------------------------------------------------------
#Apaga o conteudo
self.bitmap.clear
#--------------------------------------------------------------
#Create the HP bar
hp = $game_actors[1].hp
maxhp = $game_actors[1].maxhp
wb = 116 * hp / maxhp
self.bitmap.fill_rect(10, 14, 120, 10, @back)
self.bitmap.fill_rect(11, 15, 118, 8, @back2)
self.bitmap.fill_rect(12, 16, 116, 6, @back)
self.bitmap.gradient_fill_rect(12, 16, wb, 6, @ch1, @ch2)
self.bitmap.draw_text(10, 0, 200, 24, "HEALTH")

end

def dispose
self.bitmap.dispose
super
end
end

#--------------------------------------------------------------
#Install the HUD
class Spriteset_Map
alias :or_initialize :initialize
def initialize
@hud = HUD.new(@viewport2)
or_initialize
end
alias :or_update :update
def update
@hud.update
or_update
end
alias :or_dispose :dispose
def dispose
@hud.dispose
or_dispose
end
end
