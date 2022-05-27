#==============================================================================
# ■ 隐藏房间黑块遮罩
#  by：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
=begin
  使用说明：
   · 在地图上建一个事件，事件名为 "Black_Room_Config" 并且在该事件里注释上
  <mask=文件名（不包含后缀）>
    path: BlackRoomFiles
    color: Color.new(33,33,33)
    x: 3
    y: 0
    z: 250
    edge_width: 20
    draw: [3,9,9,13][7,0,9,9]
    check: [2,8,10,14][8,0,10,10]
    min_opacity: 75
    max_opacity: 200
    switch_id: 5
  </mask>
  · 以上的配置都有默认值，可以不配置，注释框可能不够写，可以使用滚动文字、脚本框、
     显示对话来填，用来设置黑块的事件不会被执行，推荐使用滚动文字配置，不会被换行。
  · 各字段作用释义：
       path：使用的素材所在路径，不使用素材绘制则没有意义
       color：绘制黑块时使用的颜色，使用素材绘制黑块时无效
       x: 遮罩区域的 x 坐标
       y：遮罩区域的 y 坐标
       z: 遮罩块的 z 值（在人物上方：200 同层：100 下方：0，可以做个参考）
       edge_width：绘制黑块时边缘的留白宽度，使用素材绘制黑块时无效
       draw：要绘制黑块的范围，[左上角x,左上角y,右下角x,右下角y] 写多个会进行拼接
       check：检查玩家踏入的范围，在范围内时，黑块将隐藏，设置规则同上
       min_opacity：隐藏时不透明度最低值 默认0
       max_opacity：显示时不透明度最大值 默认255
       switch_id：关联的开关，设置的开关打开时，视为玩家在范围内，将隐藏黑块
       <mask=图片名称> 标签内的文件名是在使用素材做遮罩时读取的文件名
  · 注意：
       使用素材绘制遮罩时：必须指定 x、y、check
       不用素材绘制遮罩时：x、y会自动计算，无需设置，check 如果未设置则与 draw 一致
       多个矩形之间允许重叠范围，注意不要换行，看地图编辑器右下角坐标就可以轻松取值
       Black_Room_Config 的事件可以有多个，一个事件里也可以写多个遮罩
=end
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:black_room] = 20220520
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::BlackRoom
  SW = 1                                         # 该开关开启时遮罩块不可见
  RE_OUTER   = /<mask[= ]?(.*?)>(.*?)<\/mask>/mi # 读取备注用的正则表达式
  RE_INNER   = /(\w+) *: *(.*)/                  # 读取设置用的正则表达式
  DEFAULT_Z  = 300                               # 遮罩块的Z值
  EDGE_WIDTH = 16                                # 遮罩块边距留空的距离
  EVENT_NAME = 'Black_Room_Config'               # 设置遮罩块的事件名
  DEFAULT_COLOR = Color.new(0,0,0)               # 默认遮罩块填充的颜色
  DEFAULT_PATH  = 'Parallaxes'                   # 素材存放默认文件夹 Graphics 下
  OPACITY_SPEED = 17                             # 透明度变化的速度
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================

class Sprite_BlackRoom < Sprite
  include VIPArcher::BlackRoom
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(settings, viewport)
    super(viewport)
    @settings = settings
    @check_rects = []
    basename = extract(nil)
    self.z = extract('z', DEFAULT_Z).to_i
    @switch_id = extract('switch_id', SW).to_i
    @min_opacity = extract('min_opacity', 0).to_i
    @max_opacity = extract('max_opacity', 255).to_i
    @opacity_speed = extract('opacity_speed', OPACITY_SPEED).to_i
    if basename.empty?
      return unless extract('draw')
      draw_rects = make_rects(extract('draw',''))
      make_bitmap(draw_rects)
      @check_rects = extract('check') ?
      make_rects(extract('check','')) : draw_rects
    else
      folder_name = "Graphics/#{extract('path', DEFAULT_PATH).chomp}"
      self.bitmap = Bitmap.new("#{folder_name}/#{basename}")
      if RUBY_VERSION == '1.9.2'
        p "#{basename}遮罩未设置踏入区域" unless extract('check')
      end
      @check_rects = make_rects(extract('check',''))
      self.x = extract('x', 0).to_i * 32
      self.y = extract('y', 0).to_i * 32
    end
    self.opacity = character_pos? ? @min_opacity : @max_opacity
  end
  #--------------------------------------------------------------------------
  # ● 通过备注的设置的矩形绘制 Bitmap
  #--------------------------------------------------------------------------
  def make_bitmap(draw_rects)
    bitmap_x = draw_rects.min_by { |rect| rect.x }.x
    bitmap_y = draw_rects.min_by { |rect| rect.y }.y
    bitmap_width = draw_rects.max_by { |rect| rect.width }.width
    bitmap_height = draw_rects.max_by { |rect| rect.height }.height
    self.x = bitmap_x * 32
    self.y = bitmap_y * 32
    self.bitmap = Bitmap.new(bitmap_width * 32, bitmap_height * 32)
    color = extract('color', DEFAULT_COLOR)
    edge_width = extract('edge_width', EDGE_WIDTH).to_i
    draw_rects.each do |rect|
      fill_rect = Rect.new(
        edge_width + (rect.x - bitmap_x) * 32,
        edge_width + (rect.y - bitmap_y) * 32,
        (rect.width - rect.x + 1) * 32 - edge_width * 2,
        (rect.height - rect.y + 1) * 32 - edge_width * 2
      )
      self.bitmap.fill_rect(fill_rect, color)
    end
  end
  #--------------------------------------------------------------------------
  # ● 备注字符串转矩形数组
  #--------------------------------------------------------------------------
  def make_rects(str)
    str.scan(/\[[\d, ]+?\]/mi).collect do |rect|
      eval("Rect.new(#{$1})") if rect =~ /\[(\d+.*?)\]/
    end
  end
  #--------------------------------------------------------------------------
  # ● 提取备注中的设定值
  #--------------------------------------------------------------------------
  def extract(key, default = nil)
    return eval(@settings[key]) if key == 'color' && @settings[key]
    @settings[key] || default
  end
  #--------------------------------------------------------------------------
  # ● 检查位置是否在设定的范围内
  #--------------------------------------------------------------------------
  def character_pos?
    @check_rects.any? do |rect|
      $game_player.x <= rect.width  && $game_player.x >= rect.x &&
      $game_player.y <= rect.height && $game_player.y >= rect.y
    end || $game_switches[@switch_id]
  end
  #--------------------------------------------------------------------------
  # ● 更新透明度
  #--------------------------------------------------------------------------
  def update_opacity
    self.opacity = character_pos? ?
    [self.opacity - @opacity_speed, @min_opacity].max :
    [self.opacity + @opacity_speed, @max_opacity].min
    self.visible = !$game_switches[SW]
  end
  #--------------------------------------------------------------------------
  # ● 更新地图卷动位置
  #--------------------------------------------------------------------------
  def update_position
    self.ox = $game_map.display_x * (RUBY_VERSION == '1.9.2' ? 32 : 0.125)
    self.oy = $game_map.display_y * (RUBY_VERSION == '1.9.2' ? 32 : 0.125)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    update_opacity
    update_position
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
end
#-------------------------------------------------------------------------------
class Spriteset_Map
  include VIPArcher::BlackRoom
  # 显示文字：（401） 滚动文本：（405） 注释：(108, 408) 脚本：（355, 655）
  EVENT_CODE = [108, 408, 405, 355, 655, 401] # 可以进行填写配置的事件类型编号
  #--------------------------------------------------------------------------
  # ● 生成人物精灵
  #--------------------------------------------------------------------------
  alias black_room_create_characters create_characters
  def create_characters
    old_map_id = @map_id # 兼容部分脚本 by：KB.Driver（日历的付丧神）
    black_room_create_characters
    old_map_id != @map_id ? room_sprite_dispose : return if @black_room_sprites
    create_black_rooms
  end
  #--------------------------------------------------------------------------
  # ● 生成黑色遮罩块
  #--------------------------------------------------------------------------
  def create_black_rooms
    @black_room_sprites = []
    $game_map.events.values.each do |event|
      if event.instance_variable_get(:@event).name =~ /#{EVENT_NAME}/i
        return if event.list.nil?
        event.list.unshift(
          RPG::EventCommand.new(115)
        ) if event.list.first.code != 115
        event.list.inject('') do |result, command|
          next result unless EVENT_CODE.include?(command.code)
          "#{result}#{command.parameters.join()}\n"
        end.scan(RE_OUTER).map do |name, contents|
          settings = {nil => name}
          contents.scan(RE_INNER) do |key, value|
            (settings[key] ||= '') << value
          end
          sprite = Sprite_BlackRoom.new(settings, @viewport1)
          @black_room_sprites.push(sprite)
        end
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
