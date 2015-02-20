#==============================================================================
# ■ 敌人追加掉落物
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#   在敌人的备注栏里备注<drops kind ID X%> 
#   其中 kind: i => 道具
#              w => 武器 
#              a => 防具
#          ID: 物品编号索引
#           X：概率(例如为5的话 就是 5%)
#   例如<drops w 5 55%> 就是55%的概率获得5号武器
#   注：备注多个掉落物品请记得换行,备注信息中的空格不要忘记了。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:expand_drop] = 20141101
#--------------------------------------------------------------------------------
class RPG::Enemy < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 获取备注扩展掉落信息
  #--------------------------------------------------------------------------
  def get_extra_drop_item
    expand_drop_item = []
    self.note.split(/[\r\n]+/).each{ |line|
      if line =~ /<drops((?:\s+\w+){3})%>/
        expand_item = $1.lstrip.split(/\s+/)
        expand_drop_item.push(expand_item)
      end}
    return expand_drop_item
  end
  #--------------------------------------------------------------------------
  # ● 生成扩展掉落物品实例
  #--------------------------------------------------------------------------
  def make_drop_item(drop_item)
    return nil if drop_item == []
    di = RPG::Enemy::DropItem.new
    di.kind = ["","i","w","a"].index(drop_item[0])
    di.data_id = drop_item[1].to_i
    di.denominator = 100 / drop_item[2].to_f
    return di
  end
  #--------------------------------------------------------------------------
  # ● 生成掉落物品信息数组
  #--------------------------------------------------------------------------
  alias extra_drop_items drop_items
  def drop_items
    items = extra_drop_items.clone
    get_extra_drop_item.each{|item| items.push(make_drop_item(item)) if item}
    return items
  end
end