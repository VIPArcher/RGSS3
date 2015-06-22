#==============================================================================
# ■ 隐藏房间黑块
#  by：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#  · 在需要用黑块遮罩的地图上建一个事件，事件名为 "Black_Room"并且在该事件里注释上
#  需要遮罩的范围矩形，例如 <6,4,10,17> 就为从地图坐标(6,4)开始到坐标(10,17)的矩形
#  区域填充上黑色块遮罩掉，当玩家踏入这个矩形时遮罩块消失。查看坐标可以看地图编辑器
#  右下角，把要遮罩的区域的左上角的坐标和右下角的坐标带入即可。
#  · 指定遮罩块颜色可在设置的第一行注释上<color=Color.new(R,G,B)>
#  · 每个遮罩可以指定角色踏入的矩形，规则同上，注释方法为在对应的矩形后面同一行注释
#  例如<6,4,10,17>,[6,4,10,18]，未指定踏入区域时默认原矩形为踏入区域
#  · 如需注释多个黑块房间请注意换行。
#  · 需要用图片做为遮罩块，就像这样备注 <name=文件名 x:5 y:5>,[5,5,10,10]
#   使用图片做为遮罩块必须设置踏入的矩形。文件放在"\Graphics\Parallaxes"文件夹下
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
    if rect.is_a?(Rect)
      self.x, self.y, self.z = rect.x * 32, rect.y * 32, Z
      width, height = rect.width - rect.x + 1,rect.height - rect.y + 1
      set_bitmap(width * 32,height * 32)
    elsif rect.is_a?(Array)
      self.x, self.y, self.z = rect[1] * 32, rect[2] * 32, Z
      set_bitmap(rect[0])
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置Bitmap
  #--------------------------------------------------------------------------
  def set_bitmap(*args)
    case args.size
    when 1
      self.bitmap = Cache.parallax(args[0])
    when 2
      self.bitmap = Bitmap.new(args[0], args[1])
      rect = Rect.new(Edge, Edge, args[0] - Edge * 2, args[1] - Edge * 2)
      self.bitmap.fill_rect(rect, @color)
    end
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
    self.opacity += character_pos? ? Opacity_Speed : - Opacity_Speed
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
  alias black_room_load_tileset load_tileset
  def load_tileset
    black_room_load_tileset
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
    command.parameters.each {|line|get_rect_setup(line);get_bitmap_setup(line)}
  end
  #--------------------------------------------------------------------------
  # ● 备注文件名的设置
  #--------------------------------------------------------------------------
  def get_bitmap_setup(line)
    if line =~ /<name\s*=\s*(\S+?)\s*x:\s*(\d+?)\s*y:\s*(\d+)>/i
      rect = [$1,$2.to_i,$3.to_i]
      if line =~ /\[(\d+.*?)\]/; x = $1.split(',')
        check_rect = Rect.new(x[0].to_i,x[1].to_i,x[2].to_i,x[3].to_i)
      end
      sprite = Sprite_BlackRoom.new(rect,check_rect,@color,@viewport1)
      sprite.opacity = 0 unless sprite.character_pos?
      @black_room_sprites.push(sprite)
    end
  end
  #--------------------------------------------------------------------------
  # ● 备注矩形的设置
  #--------------------------------------------------------------------------
  def get_rect_setup(line)
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
