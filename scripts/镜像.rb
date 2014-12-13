#===============================================================================
#  镜子 By：VIPArcher
#===============================================================================
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#  说明：
#    在地图下方生成人物行走图
#    当角色站在区域ID为Reflect_ID的区域时显示行走图
#    做成模仿镜子的效果。
#    事件中注释或者行走图文件名带有(reflecthide)的事件/角色不显示镜像。
#    事件中调用get_character(param).reflect_index = x
#    更改该事件/角色的镜像索引（需要用2×4）的行走图
#    param : -1 则玩家、0 则本事件、其他 则是指定的事件ID
#    x：索引ID，0~7代表8个行走图位置
#    事件移动指令中执行脚本@reflect_index = x 和上面是一样的效果
#==============================================================================
#  设定部分
#==============================================================================
module VIPArcher
  Reflect_ID = 1        # 显示镜像的区域ID
  HighReflect_ID = 2    # 显示"高一点"的镜像的区域ID
end
$VIPArcherScript ||= {};$VIPArcherScript[:reflect] = 20140917
#--------------------------------------------------------------------------------
class Game_CharacterBase;attr_accessor :reflect_index end
#==============================================================================
#  脚本部分
#==============================================================================
class Sprite_Reflect < Sprite_Character
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    h = @character.region_id == VIPArcher::HighReflect_ID ? 48 : 30
    self.x = @character.screen_x
    self.y = @character.screen_y - h
    self.z = -1
  end
  #--------------------------------------------------------------------------
  # ● 更新其他
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @character.opacity - 40
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    self.visible = region_id? && name_hide?
    self.visible = note_hide? if self.visible
    self.visible = !@character.transparent if self.visible
  end
  #--------------------------------------------------------------------------
  # ● 注释有(reflecthide)的事件不显示镜像
  #--------------------------------------------------------------------------
  def note_hide?
    return true unless @character.is_a?(Game_Event)
    return if @character.list.nil?
    @character.list.each do |command|
      if command.code == 108 or command.code == 408
        command.parameters.each do |line|
          return false if line.include?("(reflecthide)")
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 行走图文件名带有(reflecthide)的角色/事件不显示镜像
  #--------------------------------------------------------------------------
  def name_hide?
    !@character.character_name.include?("(reflecthide)")
  end
  #--------------------------------------------------------------------------
  # ● 角色/事件站在区域ID为Reflect_ID时显示镜像
  #--------------------------------------------------------------------------
  def region_id?
    @character.region_id == VIPArcher::Reflect_ID || VIPArcher::HighReflect_ID
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      index = @character.reflect_index unless @character.reflect_index.nil?
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      vip = @character.direction
      vip = 8 if @character.direction == 2
      vip = 2 if @character.direction == 8
      sy = (index / 4 * 4 + (vip - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #--------------------------------------------------------------------------
  # ● 开始显示心情动画
  #--------------------------------------------------------------------------
  def start_balloon(*args) end;def start_animation(*args) end
end
#--------------------------------------------------------------------------------
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 生成镜像精灵
  #--------------------------------------------------------------------------
  alias vip_20140917_create_characters create_characters
  def create_characters
    vip_20140917_create_characters
    @character_reflect_sprites = []
    $game_map.events.values.each do |event|
      @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1, event))
    end
    $game_player.followers.reverse_each do |follower|
      @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1, follower))
    end
    @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1, $game_player))  
  end
  #--------------------------------------------------------------------------
  # ● 释放镜像精灵
  #--------------------------------------------------------------------------
  alias vip_20140917_dispose_characters dispose_characters
  def dispose_characters
    vip_20140917_dispose_characters
    @character_reflect_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 刷新镜像精灵
  #--------------------------------------------------------------------------
  alias vip_20140917_update_characters update_characters
  def update_characters
    vip_20140917_update_characters
    @character_reflect_sprites.each {|sprite| sprite.update }
  end
end