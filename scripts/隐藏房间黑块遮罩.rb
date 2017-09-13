#==============================================================================
# ■ 隐藏房间黑块 v2.0
#  by：VIPArcher time：20150211
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#  · 指定遮罩块颜色可在设置的第一行注释上<color=Color.new(R,G,B)>
#  · 在需要用黑块遮罩的地图上建一个事件，事件名为 "Black_Room"并且在该事件里注释上
#  需要遮罩的矩形范围，一行注释设定一个遮罩块，注释示例参考如下：
#  · 使用颜色RGB都为12的颜色填充区域ID为和1,2的区域踏入时隐藏该黑色遮罩块
#     <color=Color.new(12,12,12) regid=[1,2]>
#  · 使用颜色RGB都为12的颜色填充x坐标10,y坐标12,宽度4格,高度6格的的区域遮罩
#     <color=Color.new(100,255,255) x=10 y=12 w=4 h=6>
#  · 使用文件名都为 遮罩_A.png 的图片填充x坐标10,y坐标12,触发隐藏区域ID为3的遮罩
#     <name=遮罩_A x=10 y=12 regid=[3]>
#  · 使用脚本默认颜色填充触发隐藏区域ID为8的遮罩 <black regid=[8]>
#   使用图片做为遮罩块必须设置踏入的矩形。文件放在"\Graphics\Parallaxes"文件夹下
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:black_room] = 20170913
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::BlackRoom
  Z = 200                              # 遮罩块的Z值
  SW = 1                              # 该开关开启时遮罩块不可见
  Edge = 16                           # 遮罩块边距留空的距离
  Room_Color = Color.new(0,0,0)       # 默认遮罩块填充的颜色
  Event_Name = 'Black_Room'           # 设置遮罩块的事件名
  Opacity_Speed = 16                  # 透明度变化的速度
  File_Path = "Graphics/Parallaxes/"  # 如果使用图片遮罩图片的路径
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Sprite_BlackRoom < Sprite
  include VIPArcher::BlackRoom
  def initialize(settings, viewport = nil)
    super(viewport)
    @settings, self.z, @player = settings, Z, $game_player
    get_size_pos
    create_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 设置遮罩图位置大小信息
  #--------------------------------------------------------------------------
  def get_size_pos
    if @settings['rect']
      r = @settings['rect'].scan(/\d+/).collect(&:to_i)
      @rect = Rect.new(r[0], r[1], r[2], r[3])
      self.x, self.y = @rect.x * 32, @rect.y * 32
      @bitmap_width  = @rect.width  - @rect.x + 1
      @bitmap_height = @rect.height - @rect.y + 1
    elsif @settings['regid']
      @res, @pos = @settings['regid'].scan(/\d+/).collect(&:to_i), []
      $game_map.data.xsize.times do |x|
        $game_map.data.ysize.times do |y|
          @pos.push [x,y] if @res.include?($game_map.data[x, y, 3] >> 8)
        end
      end
      return p "似乎备注了未设置区域ID的遮罩块" if @pos.size.zero?
      @pos.each do |p|
        @min_x = p[0] if !@min_x || @min_x > p[0]
        @min_y = p[1] if !@min_y || @min_y > p[1]
        @max_x = p[0] if !@max_x || @max_x < p[0]
        @max_y = p[1] if !@max_y || @max_y < p[1]
      end
      @bitmap_width  = (@max_x - @min_x + 1) * 32 + Edge * 2
      @bitmap_height = (@max_y - @min_y + 1) * 32 + Edge * 2
      self.x, self.y = (@min_x * 32 - Edge), (@min_y * 32 - Edge)
    end
    self.x = @settings['x'].to_i * 32 if @settings['x']
    self.y = @settings['y'].to_i * 32 if @settings['y']
    @bitmap_width = @settings['w'].to_i * 32 if @settings['w']
    @bitmap_height = @settings['h'].to_i * 32 if @settings['h']
    if @settings['x'] && @settings['h']
      @rect = Rect.new(
        @settings['x'].to_i,  @settings['y'].to_i,
        @settings['x'].to_i + @settings['w'].to_i - 1,
        @settings['y'].to_i + @settings['h'].to_i - 1
      )
    end
  end
  #--------------------------------------------------------------------------
  # ● 创建遮罩图像
  #--------------------------------------------------------------------------
  def create_bitmap
    if @settings['name']
      self.bitmap = Cache.load_bitmap(File_Path, @settings['name'])
    else
      self.bitmap = Bitmap.new(@bitmap_width, @bitmap_height)
      color = @settings['color'] ? eval(@settings['color']) : Room_Color
      if @pos && !@pos.size.zero?
        @pos.each do |pos|
          bitmap.fill_rect(
            (pos[0] - @min_x) * 32,
            (pos[1] - @min_y) * 32,
            32 + Edge * 2, 32 + Edge * 2, color
          )
        end
      else
        self.bitmap.fill_rect(Edge, Edge, @bitmap_width - Edge * 2,
          @bitmap_height - Edge * 2, color)
      end
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
    if @rect
      @player.x > @rect.width  || @player.x <  @rect.x ||
      @player.y > @rect.height || @player.y <  @rect.y
    elsif @res
      !@res.include?($game_map.region_id(@player.x, @player.y + 1)) &&
      !@res.include?($game_map.region_id(@player.x - 1, @player.y)) &&
      !@res.include?($game_map.region_id(@player.x + 1, @player.y)) &&
      !@res.include?($game_map.region_id(@player.x, @player.y - 1)) &&
      !@res.include?($game_map.region_id(@player.x,     @player.y))
    end
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
  alias black_room_create_characters create_characters
  def create_characters
    black_room_create_characters
    room_sprite_dispose if @black_room_sprites
    @black_room_sprites = []
    $game_map.events.values.each do |event|
      if event.instance_variable_get(:@event).name =~ /#{Event_Name}/i
        event.list.each do |command|
          get_black_room_setup(command) if [108, 408].include?(command.code)
        end if event.list
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取遮罩块设置
  #--------------------------------------------------------------------------
  def get_black_room_setup(command)
    command.parameters.each do |line|
      settings = {}
      if line =~ /<name *= *(.*?) +(.*?)>/i
        settings['name'] = $1
      elsif line =~ /<color *= *(.*?) +(.*?)>/i
        settings['color'] = $1
      else
        line =~ /<black( +)(.*?)>/i
      end
      get_settings(settings, $2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 解析备注生成遮罩块
  #--------------------------------------------------------------------------
  def get_settings(settings, opt)
    opt.scan(/(\w+) *= *([\d\[,\]]*)/) do |key, value|
      (settings[key] ||= '') << value
    end
    sprite = Sprite_BlackRoom.new(settings, @viewport1)
    sprite.opacity = 0 unless sprite.character_pos?
    @black_room_sprites.push(sprite)
  end
  #--------------------------------------------------------------------------
  # ● 释放遮罩块
  #--------------------------------------------------------------------------
  alias black_room_dispose dispose
  def dispose
    black_room_dispose
    @black_room_sprites.each {|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # ● 更新遮罩块
  #--------------------------------------------------------------------------
  alias black_room_update update
  def update
    black_room_update
    @black_room_sprites.each {|sprite| sprite.update }
  end
end
