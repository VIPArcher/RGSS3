#==============================================================================
# ■ 物品分类扩展
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#   在设定区设定好分类后在道具/武器/防具备注栏备注
#   <分类:分类名称>
#   即可把对应物品归到对应分类下，备注未填写分类的物品按默认分类归类
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:item_category] = 20141017
#==============================================================================
# ● 设定区
#==============================================================================
module VIPArcher end
module VIPArcher::ITEM
  MAX_COL  = 4 # 一页显示的分类列数
  CATEGORY = { #  <- 别删
#格式:分类标识符号 => "分类名称", 注：标识尽量独特不重复即可
      :item       => "道具", #默认分类
      :weapon     => "武器", #默认分类
      :armor      => "护甲", #默认分类
      :key_item   => "贵重", #默认分类
      :viparcher  => "VIP",
      #在这里继续添加...
  } #  <- 别删
end
#--------------------------------------------------------------------------------
class Window_ItemList < Window_Selectable
  include VIPArcher::ITEM
  #--------------------------------------------------------------------------
  # ● 查询列表中是否含有此物品
  #--------------------------------------------------------------------------
  alias vip_include? include?
  def include?(item)
    if item && item.note =~ /<(?:category|分类)[: ].*>/i
      note_include?(item)
    else
      vip_include?(item)
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查备注分类
  #--------------------------------------------------------------------------
  def note_include?(item)
    item.note =~ /<(?:category|分类)[:]\s*#{CATEGORY[@category]}>/i
  end
end
#--------------------------------------------------------------------------------
class Window_ItemCategory < Window_HorzCommand
  include VIPArcher::ITEM
  #--------------------------------------------------------------------------
  # ● 生成指令列表
  #--------------------------------------------------------------------------
  def make_command_list
    CATEGORY.each{|key, value| add_command(value,key)}
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max; MAX_COL end
end
