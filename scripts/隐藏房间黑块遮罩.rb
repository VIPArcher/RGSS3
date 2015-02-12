#==============================================================================
# ■ 隐藏房间黑块
#  by：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：在需要用黑块遮罩的地图上建一个事件，事件名为 "Black_Room" 
#  并且在该事件里注释上需要遮罩的范围矩形
#  例如 <6,4,10,17> 就为从地图坐标 x:6,y:4开始到坐标x:10,y:17的矩形区域填充上黑色
#  块遮罩掉，当玩家踏入这个矩形时遮罩块消失。查看坐标可以看地图编辑器右下角，把要
#  遮罩的区域的左上角的坐标和右下角的坐标带入即可。
#  指定遮罩块颜色可在设置的第一行注释上<color=Color.new(R,G,B)>
#  每个遮罩可以指定角色踏入的矩形，规则同上，注释方法为在对应的矩形后面同一行注释
#  例如<6,4,10,17>,[6,4,10,18]，未指定踏入区域时默认原矩形为踏入区域
#  如需注释多个黑块房间请注意换行。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:black_room] = 20150211
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::BlackRoom
  Z = 999                        # 遮罩块的Z值
  SW = 1                         # 该开关开启时遮罩块不可见
  Edge = 16                      # 遮罩块边距留空的距离
  Room_Color = Color.new(0,0,0)  # 默认遮罩块填充的颜色
  Event_Name = 'Black_Room'      # 设置遮罩块的事件名
  Opacity_Speed = 17             # 透明度变化的速度
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Sprite_BlackRoom < Sprite
  include VIPArcher::BlackRoom
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(rect,check_rect,color,viewport)
    super(viewport)
    @check_rect, @color = check_rect,color
    self.x, self.y, self.z = rect.x * 32, rect.y * 32, Z
    width, height = rect.width - rect.x + 1,rect.height - rect.y + 1
    set_bitmap(self.x,self.y,width * 32,height * 32)
  end
  #--------------------------------------------------------------------------
  # ● 设置Bitmap
  #--------------------------------------------------------------------------
  def set_bitmap(x,y,width,height)
    self.bitmap = Bitmap.new(width, height)
    rect = Rect.new(Edge, Edge, width - Edge * 2, height - Edge * 2)
    self.bitmap.fill_rect(rect, @color)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    self.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # ● 位置判定
  #--------------------------------------------------------------------------
  def character_pos?
    $game_player.x > @check_rect.width  || $game_player.x <  @check_rect.x ||
    $game_player.y > @check_rect.height || $game_player.y <  @check_rect.y
  end
  #--------------------------------------------------------------------------
  # ● 更新透明度
  #--------------------------------------------------------------------------
  def update_opacity
    self.opacity += character_pos? ? Opacity_Speed : -Opacity_Speed
    self.opacity = 0 if $game_switches[SW]
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    self.ox = $game_map.display_x * 32
    self.oy = $game_map.display_y * 32
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_opacity
    update_position
  end
end
#-------------------------------------------------------------------------------
class Spriteset_Map
  include VIPArcher::BlackRoom
  #--------------------------------------------------------------------------
  # ● 生成黑色遮罩块
  #--------------------------------------------------------------------------
  alias black_room_create_characters create_characters
  def create_characters
    black_room_create_characters
    room_sprite_dispose if @black_room_sprites
    @black_room_sprites = []
    $game_map.events.values.each do |event|
      if event.instance_variable_get(:@event).name =~ /#{Event_Name}/i
        return if event.list.nil?
        event.list.each { |command| get_setup(command) }
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取遮罩块设置
  #--------------------------------------------------------------------------
  def get_setup(command)
    return unless command.code == 108 or 408
    command.parameters.each do |line|
      @color = eval($1) if line =~ /<color\s*=\s*(.*?)\s*>/i
      @color ||= Room_Color
      if line =~ /<(\d+.*?)>/; x = $1.split(',')
        check_rect = rect = Rect.new(x[0].to_i,x[1].to_i,x[2].to_i,x[3].to_i)
        if line =~ /\[(\d+.*?)\]/; x = $1.split(',')
          check_rect = Rect.new(x[0].to_i,x[1].to_i,x[2].to_i,x[3].to_i)
        end
        sprite = Sprite_BlackRoom.new(rect,check_rect,@color,@viewport1)
        sprite.opacity = 0 unless sprite.character_pos?
        @black_room_sprites.push(sprite)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  alias black_room_dispose dispose
  def dispose
    black_room_dispose
    room_sprite_dispose
  end
  #--------------------------------------------------------------------------
  # ● 释放遮罩块
  #--------------------------------------------------------------------------
  def room_sprite_dispose
    @black_room_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias black_room_update update
  def update
    black_room_update
    @black_room_sprites.each {|sprite| sprite.update }
  end
end