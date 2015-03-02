#==============================================================================
# ■ 剧情中黑色边框
#  by：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#  · 剧情开始时打开开关，淡入黑边框，执行剧情。剧情结束时关闭开关，无需素材。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:black_message] = 20150225
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::Black_Message_Layer
  Z = 1                          # Z值
  SW = 1                         # 控制淡入/淡出的开关ID
  Edge = 24                      # 边距渐变的高度
  Width = 544                    # 宽度
  Height = 40                    # 彻底填充的高度
  Black_Color = Color.new(0,0,0) # 填充的颜色
  Oy_Speed = 4                   # y 轴方向淡出淡入速度
  Opacity_Speed = 16             # 透明度变化的速度
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Sprite_Message_Layer < Sprite
  include VIPArcher::Black_Message_Layer
  H = Height + Edge
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(pos = false,viewport = nil)
    super(viewport)
    @pos = pos
    self.opacity, self.z = 0 , Z
    self.oy = @pos ? H : -H
    set_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 设置位图
  #--------------------------------------------------------------------------
  def set_bitmap
    rect1 = Rect.new(0,@pos ? 0  : Edge,Width,Height)
    rect2 = Rect.new(0,@pos ? Height :  0,Width,Edge)
    self.bitmap = Bitmap.new(544,H)
    self.y = Graphics.height - bitmap.height unless @pos
    color1,color2 = Black_Color,Color.new
    self.bitmap.fill_rect(rect1, color1)
    self.bitmap.gradient_fill_rect(rect2, 
      @pos ? color1 : color2, @pos ? color2 : color1,true)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    update_fadeout unless $game_switches[SW]
    update_fadein if $game_switches[SW]
  end
  #--------------------------------------------------------------------------
  # ● 淡出淡入刷新
  #--------------------------------------------------------------------------
  def update_fadein
    if oy.abs > 0
      self.oy += @pos ? -Oy_Speed : Oy_Speed
      self.opacity += Opacity_Speed
    end
  end
  #--------------------------------------------------------------------------
  # ● 淡出淡出刷新
  #--------------------------------------------------------------------------
  def update_fadeout
    if oy.abs < H
      self.oy += @pos ? Oy_Speed : -Oy_Speed
      self.opacity -= Opacity_Speed
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    super
    self.bitmap.dispose
  end
end
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 创建剧情黑框层
  #--------------------------------------------------------------------------
  alias message_layer_sprite_create_timer create_timer
  def create_timer
    message_layer_sprite_create_timer
    @down_message_layer = Sprite_Message_Layer.new(false,@viewport2)
    @up_message_layer = Sprite_Message_Layer.new(true,@viewport2)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  alias message_layer_sprite_dispose dispose
  def dispose
    message_layer_sprite_dispose
    @up_message_layer.dispose
    @down_message_layer.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias message_layer_sprite_update update
  def update
    message_layer_sprite_update
    @up_message_layer.update
    @down_message_layer.update
  end
end