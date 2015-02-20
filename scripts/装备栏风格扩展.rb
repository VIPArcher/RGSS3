#==============================================================================
# +++ 装备栏风格扩展 +++
#  by：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 　■ 新增装备风格
# 使用说明：在角色备注栏/职业备注栏里备注 <slot_type:x> 则角色变为x号装备风格,
#   一个角色有多个风同时存在时最终返回x编号最大的那个风格。
#   在防具上备注<etype_id:x>则把该防具设置为第x种类型,默认占用了0-4,追加的由5开始
#   在任何有备注框的地方备注 <fix_equips:x> 固定该位置的装备，固定多个则换行再写
#   在任何有备注框的地方备注 <seal_equips:x> 禁用该位置的装备，禁用多个则换行再写
#   在角色备注栏备注<ini_equips:[a,b,c...n]> 初始化初始装备（此备注将使数据库的初
#   始装备设置失效，并且请把装备对应好位置和确认装备该位置可以装备该装备。）
#   在角色备注栏备注<add_equips:[h,i,j...n]> 追加初始装备（和上面是一样的意思，
#   但是这种不会让数据库的设置无效，只会在后面追加上初始装备。）具体请自己摸索吧
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:slot_type] = __FILE__ #20140803
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher
 
  ETYPE_ADD_NAME = ["腰带", "鞋子"] #设置要增加的装备位置的名字
 
  SLOT_TYPE = {
  0 => [0,1,2,3,4],    # 普通  
  1 => [0,0,2,3,4],    # 双持武器 （这两个是默认的风格）
  # 从这里开始添加装备风格
  2 => [0,0,0,2,3,4,5],  # 看我索爷三刀流
  3 => [4],            # 窝只是个需要保护的NPC装备只要首饰就够了吧。
  4 => [0,2,3,3],       # 233
  5 => [0,1,2,3,4,5,6] # 这里的5,6对应的类型就是上面追加的类型
  # 在这里继续添加类型。编号越大，优先级越高。
 
  } # <= 这个大括号不能删
  #--------------------------------------------------------------------------
  # ● 追加装备位置用语
  #--------------------------------------------------------------------------
  def Vocab.etype(etype_id)
    etype_name = $data_system.terms.etypes + ETYPE_ADD_NAME
    etype_name[etype_id]
  end
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class RPG::Actor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 初始装备数组
  #--------------------------------------------------------------------------
  alias vip_20141119_equips equips
  def equips
    add_equips = []
    $1.split(",").each {|item|add_equips.push item.to_i} if
    @note =~ /<(?:ini_equips|初始装备)[:]\[(.+?)\]>/i
    return add_equips if add_equips != []
    $1.split(",").each {|item|add_equips.push item.to_i} if
    @note =~ /<(?:add_equips|追加初始装备)[:]\[(.+?)\]>/i
    vip_20141119_equips.clone + add_equips
  end
end
#-------------------------------------------------------------------------------
class RPG::Armor < RPG::EquipItem
  #--------------------------------------------------------------------------
  # ● 装备类型
  #--------------------------------------------------------------------------
  def etype_id
    return @note =~ /<(?:etype_id|装备类型)[:]\s*(.*)>/i ? $1.to_i : @etype_id
  end
end
#-------------------------------------------------------------------------------
class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 获取装备风格
  #--------------------------------------------------------------------------
  def slot_type
    slot =[]
    feature_objects.each {|obj| slot.push $1.to_i if 
    obj.note  =~ /<(?:slot_type|装备风格)[:]\s*(.*)>/i }
    return slot.max || 0
  end
  #--------------------------------------------------------------------------
  # ● 判定是否固定装备
  #--------------------------------------------------------------------------
  alias vip_20141119_equip_type_fixed? equip_type_fixed?
  def equip_type_fixed?(etype_id)
    fixed_type = []
    feature_objects.each {|obj| obj.note.split(/[\r\n]+/).each {|line|
    fixed_type.push $1.to_i if line =~ /<(?:fix_equips|固定装备)[:]\s*(.*)>/i}}
    fixed_type.include?(etype_id) || vip_20141119_equip_type_fixed?(etype_id)
  end
  #--------------------------------------------------------------------------
  # ● 判定装备是否被禁用
  #--------------------------------------------------------------------------
  alias vip_20141119_equip_type_sealed? equip_type_sealed?
  def equip_type_sealed?(etype_id)
    sealed_type = []
    feature_objects.each {|obj| obj.note.split(/[\r\n]+/).each {|line|
    sealed_type.push $1.to_i if line =~ /<(?:seal_equips|禁用装备)[:]\s*(.*)>/i}}
    sealed_type.include?(etype_id) || vip_20141119_equip_type_sealed?(etype_id)
  end
end
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 初始化装备
  #     # 方法覆盖，可能引起冲突
  #--------------------------------------------------------------------------
  def init_equips(equips)
    type_size = VIPArcher::SLOT_TYPE.values.max_by{|type|type.size}.size
    @equips = Array.new(type_size) { Game_BaseItem.new }
    equips.each_with_index do |item_id, i|
      etype_id = index_to_etype_id(i)
      slot_id = empty_slot(etype_id)
      @equips[slot_id].set_equip(etype_id == 0, item_id) if slot_id
    end
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取装备栏的数组
  #--------------------------------------------------------------------------
  alias vip_20140803_es equip_slots
  def equip_slots
    return VIPArcher::SLOT_TYPE[slot_type] if 
    VIPArcher::SLOT_TYPE[slot_type] != nil
    vip_20140803_es
  end
end
#-------------------------------------------------------------------------------
class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 生成装备栏窗口
  #--------------------------------------------------------------------------
  alias slot_vip_create_slot_window create_slot_window
  def create_slot_window
    slot_vip_create_slot_window
    @slot_window.create_contents
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  alias slot_vip_on_item_ok on_item_ok
  def on_item_ok
    slot_vip_on_item_ok
    @slot_window.create_contents
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 指令“全部卸下”
  #--------------------------------------------------------------------------
  alias slot_vip_command_clear command_clear
  def command_clear
    slot_vip_command_clear
    @slot_window.create_contents
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 指令“最强装备”
  #--------------------------------------------------------------------------
  alias slot_vip_command_optimize command_optimize
  def command_optimize
    slot_vip_command_optimize
    @slot_window.create_contents
    @slot_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● 切换角色
  #--------------------------------------------------------------------------
  alias slot_vip_on_actor_change on_actor_change
  def on_actor_change
    slot_vip_on_actor_change
    @slot_window.create_contents
    @slot_window.refresh
  end
end