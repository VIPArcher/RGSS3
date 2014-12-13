
#该脚本写得相当随意，如果冲突或者无效请放弃使用
class Game_Battler
 
  def damage_valid?
    !(actor? ? actor : enemy).note.include?('<我不是杂鱼>') ||
      friends_unit.alive_members == [self] 
  end
 
  alias assign_hp_20140817 hp=
  def hp=(hp)
    assign_hp_20140817(hp) if hp >= @hp || damage_valid?
  end
 
  alias mdv_20140817 make_damage_value
  def make_damage_value(user, item)
    mdv_20140817(user, item) if damage_valid?
  end
 
end
