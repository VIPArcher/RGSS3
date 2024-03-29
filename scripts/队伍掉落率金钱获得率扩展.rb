#===============================================================================
# ■ 队伍掉率扩展
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
# ■ 通过备注改变队伍能力的掉落率，由于是直接覆盖了原方法，
# 所以特性里的双倍掉率，双倍金钱无效了。这点请注意
# 使用说明：
#   在角色|职业|装备|状态的备注栏备注上对应的信息
#   改变物品掉率备注<物品掉率:X%> X为概率 可为负数、小数
#   改变金钱掉率备注<金钱掉率:X%> X为概率 可为负数、小数
#   同时存在多个备注可叠加，最终的掉率为(100 + 总的掉率改变量)%
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:exdrop_rate] = __FILE__ #20141103
#-------------------------------------------------------------------------------
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 获取物品掉率的倍率
  #--------------------------------------------------------------------------
  def drop_item_rate
    return $game_party.party_drop_rate
  end
end
#-------------------------------------------------------------------------------
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ● 获取金钱的倍率
  #--------------------------------------------------------------------------
  def gold_rate
    return $game_party.gold_drop_rate
  end
end
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 获取全队伍物品掉率总值
  #--------------------------------------------------------------------------
  def party_drop_rate
    drop_rate = 100
    battle_members.each {|actor| actor.feature_objects.each {|obj|
    drop_rate += $1.to_f if obj.note =~ /<物品掉率:\s*([0-9+.-]+)%>/}}
    return drop_rate / 100
  end
  #--------------------------------------------------------------------------
  # ● 获取全队伍金钱掉率总值
  #--------------------------------------------------------------------------
  def gold_drop_rate
    gold_rate = 100
    battle_members.each {|actor| actor.feature_objects.each {|obj|
    gold_rate += $1.to_f if obj.note =~ /<金钱掉率:\s*([0-9+.-]+)%>/}}
    return gold_rate / 100
  end
end