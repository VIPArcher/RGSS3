#==============================================================================
# ■ 物品颜色描绘
# By ：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:itemcolor] = 20141007
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::ItemColor
  RIM = true #是否描绘边框
  FILL = true #是否填充边框
  #为了方便设置品质等级，
  Color_Lv = {
# 品质 => 控制符颜色编号,
    0  =>  0,
    1  =>  24,
    2  =>  1,
    3  =>  30,
    4  =>  27,
    5  =>  18,
    6  =>  14
    # 继续添加
  };Color_Lv.default = 0 #这行不能删
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class RPG::BaseItem
  include VIPArcher::ItemColor
  #--------------------------------------------------------------------------
  # ● 获取道具的品质
  #--------------------------------------------------------------------------
  def color
    @note =~ /\<(?:color|品质|颜色)\s*(\d+)\>/i
    [[$1.to_i,Color_Lv.size - 1].min,0].max
  end
end
#-------------------------------------------------------------------------------
class Window_Base < Window
  include VIPArcher::ItemColor
  #--------------------------------------------------------------------------
  # ● 描绘物品
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    item_color = text_color(Color_Lv[item.color])
    change_color(item_color, enabled)
    self.color_fill_rect(x,y,item_color) if RIM
    draw_icon(item.icon_index, x, y, enabled)
    draw_text(x + 24, y, width, line_height, item.name)
  end
  #--------------------------------------------------------------------------
  # ● 绘制图标边框
  #--------------------------------------------------------------------------
  def color_fill_rect(x,y,item_color)
    item_alpha = item_color.clone
    item_alpha.alpha = 160
    contents.fill_rect(x+1 ,y+1 ,22, 22 ,item_alpha) if FILL
    contents.fill_rect(x+1 ,y+1 ,22, 1  ,item_color)
    contents.fill_rect(x   ,y+2 ,1 , 20 ,item_color)
    contents.fill_rect(x+1 ,y+22,22, 1  ,item_color)
    contents.fill_rect(x+23,y+2 ,1 , 20 ,item_color)
  end
end