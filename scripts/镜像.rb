#===============================================================================
#  镜子 v1.2 By：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#===============================================================================
#  说明：
#    在地图下方生成人物行走图做成模仿镜子的效果。站在指定区域时镜像才可见
#    事件中注释或者行走图文件名带有(reflecthide)的事件/角色不显示镜像。
#    事件中调用get_character(param).reflect_index = x
#    事件中调用get_character(param).reflect_name = "行走图文件名"
#    更改该事件/角色的镜像的行走图
#    param : -1 则玩家、0 则本事件、其他 则是指定的事件ID
#    x：索引ID，0~7代表8个行走图位置
#    事件移动指令中执行脚本@reflect_name = "行走图文件名"
#    或 @reflect_index = x 和上面是一样的效果
#===============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:reflect] = 20140917
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
#  ☆ 设定部分 ☆
#==============================================================================
module VIPArcher::Reflect
  
  Z = -1 #显示镜像的z坐标（调的太低或太高可能会被其他不必要的物件遮挡
  
  REG_SY = {  #设置可见镜像的区域ID以及对镜像高度调整的值
    #区域ID => 镜像“高度”
       1    =>    30,
       2    =>    48,
       3    =>    54
  };REG_SY.default = 0 #这行不能删
end
#==============================================================================
#  ★ 设定结束 ★
#==============================================================================
class Game_CharacterBase ; attr_accessor :reflect_index , :reflect_name end
#==============================================================================
#  脚本部分
#==============================================================================
class Sprite_Reflect < Sprite_Character
  include VIPArcher::Reflect
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #     character : Game_Character
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    character.reflect_name  ||= character.character_name
    character.reflect_index ||= character.character_index
    super(viewport, character)
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    self.mirror , self.x , self.z = true , @character.screen_x , Z
    self.y = @character.screen_y - REG_SY[@character.region_id]
  end
  #--------------------------------------------------------------------------
  # ● 更新其他
  #--------------------------------------------------------------------------
  def update_other
    self.opacity = @character.opacity - 40
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
    self.visible = region_id? && !name_hide? && !note_hide?
    self.visible = !@character.transparent if self.visible
  end
  #--------------------------------------------------------------------------
  # ● 注释有(reflecthide)的事件不显示镜像
  #--------------------------------------------------------------------------
  def note_hide?
    return unless @character.is_a?(Game_Event)
    return if @character.list.nil?
    @character.list.each do |command|
      if command.code == 108 or command.code == 408
        command.parameters.each do |line|
          return true if line.include?("(reflecthide)")
        end
      end
    end ; false
  end
  #--------------------------------------------------------------------------
  # ● 行走图文件名带有(reflecthide)的角色/事件不显示镜像
  #--------------------------------------------------------------------------
  def name_hide? ; @character.character_name.include?("(reflecthide)") end
  #--------------------------------------------------------------------------
  # ● 角色/事件站在区域ID为REG_SY时才显示镜像
  #--------------------------------------------------------------------------
  def region_id? ; REG_SY.has_key?(@character.region_id) end
  #--------------------------------------------------------------------------
  # ● 更新源位图（Source Bitmap）
  #--------------------------------------------------------------------------
  def update_bitmap
    return unless graphic_changed?
    @character_name = @character.reflect_name
    @character_index = @character.reflect_index
    set_character_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 判定图像是否被更改
  #--------------------------------------------------------------------------
  def graphic_changed?
    @character_name != @character.reflect_name ||
    @character_index != @character.reflect_index
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    index = @character.reflect_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (8 - @character.direction) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #--------------------------------------------------------------------------
  # ● 取消心情动画显示
  #--------------------------------------------------------------------------
  def setup_new_effect ; end
end
#-------------------------------------------------------------------------------
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 生成镜像精灵
  #--------------------------------------------------------------------------
  alias reflect_create_characters create_characters
  def create_characters
    reflect_create_characters
    @character_reflect_sprites = []
    $game_map.events.values.each do |event|
      @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1, event))
    end
    $game_player.followers.reverse_each do |follower|
      @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1,follower))
    end
    @character_reflect_sprites.push(Sprite_Reflect.new(@viewport1,$game_player))
  end
  #--------------------------------------------------------------------------
  # ● 释放镜像精灵
  #--------------------------------------------------------------------------
  alias reflect_dispose_characters dispose_characters
  def dispose_characters
    reflect_dispose_characters
    @character_reflect_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 刷新镜像精灵
  #--------------------------------------------------------------------------
  alias reflect_update_characters update_characters
  def update_characters
    reflect_update_characters
    @character_reflect_sprites.each {|sprite| sprite.update }
  end
end