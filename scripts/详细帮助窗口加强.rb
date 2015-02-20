#==============================================================================
# ■ 技能物品说明增强 蓝本：wyongcan
# 修改 ：VIPArcher [email: VIPArcher@sina.com]
#
# 改动说明：
# 改用新的帮助窗口和新定义draw_text_vip方法来增强兼容性
# 更改初始化数据时机以支持跳过标题
# 追加对普通物品和技能的说明内容
# 修改了对帮助窗口行数的计算以支持控制符
# 加上了各种颜色的设置，具体更高级的玩法自己领悟吧
# 改成光标不动一段时间后才会出现帮助窗口
# 2015.01.25 : 无聊的的修改(重写)[划掉]可以无视[划掉]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:help_ex] = __FILE__ #20141007
$VIPArcherScript[:equip_limit] = false #是否使用了后知后觉的装备能力限制
module VIPArcher end
#-------------------------------------------------------------------------------
class << DataManager
  alias_method :vip_load_database, :load_database
  #--------------------------------------------------------------------------
  # ● 读取数据库
  #--------------------------------------------------------------------------
  def load_database
    vip_load_database ; VIPArcher::Help_Ex.init_ready
  end
end
#==============================================================================
# ★ 设定项目 - BEGIN Setting ★
#==============================================================================
module VIPArcher::Help_Ex
  #--------------------------------------------------------------------------
  # ● 常量设置
  #--------------------------------------------------------------------------
  TIME = 60 #帮助窗口自动出现的时间（单位帧
  Font_Name = Font.default_name # 推荐"微软雅黑"
  Font_Size = 14                # "微软雅黑"的话就20号字体
  UP   = 24 #能力值提升颜色编号
  DOWN = 25 #能力值下降颜色编号
  VIP  = 14 #特殊能力颜色编号
  MP   = 23 #消耗MP的颜色编号
  TP   = 29 #消耗TP的颜色编号
  #--------------------------------------------------------------------------
  # ● 用语设置
  #--------------------------------------------------------------------------
  CODE ={
    11 => "属性抗性",
    12 => "弱化抗性",
    13 => "状态抗性",
    14 => "状态免疫",
    21 => "普通能力",
    22 => "添加能力",
    23 => "特殊能力",
    31 => "附带属性",
    32 => "附带状态",
    33 => "攻击速度",
    34 => "添加攻击次数",
    41 => "添加技能类型",
    42 => "禁用技能类型",
    43 => "添加技能",
    44 => "禁用技能",
    51 => "可装备武器类型",
    52 => "可装备护甲类型",
    53 => "固定装备",
    54 => "禁用装备",
    55 => "装备风格",
    61 => "添加行动次数",
    62 => "特殊标志",
    63 => "消失效果",
    64 => "队伍能力"
  }
  #特殊标志
  FLAG ={
    0 => "自动战斗",
    1 => "擅长防御",
    2 => "保护弱者",
    3 => "特技专注"
  }
  #技能效果范围
  SCOPE ={
    0 => "无",
    1 => "单个敌人",
    2 => "全体敌人",
    3 => "一个随机敌人",
    4 => "两个随机敌人",
    5 => "三个随机敌人",
    6 => "四个随机敌人",
    7 => "单个队友",
    8 => "全体队友",
    9 => "单个队友(战斗不能)",
    10 => "全体队友(战斗不能)",
    11 => "使用者"
  }
  #技能命中类型
  HIT ={
    0 => "必定命中",
    1 => "物理攻击",
    2 => "魔法攻击"
  }
  #使用限制
  OCCASION ={
    0 => "随时可用",
    1 => "仅战斗中",
    2 => "仅菜单中",
    3 => "不能使用"
  }
  #添加能力
  XPARAM ={
    0 => "物理命中几率：",
    1 => "物理闪避几率：",
    2 => "必杀几率:",
    3 => "必杀闪避几率：",
    4 => "魔法闪避几率：",
    5 => "魔法反射几率：",
    6 => "物理反击几率：",
    7 => "体力值再生速度：",
    8 => "魔力值再生速度：",
    9 => "特技值再生速度："
  }
  #特殊能力
  SPARAM ={
    0 => "受到攻击的几率",
    1 => "防御效果比率",
    2 => "恢复效果比率",
    3 => "药理知识",
    4 => "MP消费率",
    5 => "TP消耗率",
    6 => "物理伤害加成",
    7 => "魔法伤害加成",
    8 => "地形伤害加成",
    9 => "经验获得加成"
  }
  #装备风格  require 装备风格扩展脚本 by：VIPArcher
  SLOT_TYPE ={
    0 => "普通",
    1 => "双持武器",
    2 => "索爷三刀流",
    3 => "NPC",
    4 => "233",
    5 => "论坛@的BUG好烦啊"
  }
  #队伍能力
  PARTY_ABILITY ={
    0 => "遇敌几率减半",
    1 => "随机遇敌无效",
    2 => "敌人偷袭无效",
    3 => "先制攻击几率上升",
    4 => "获得金钱数量双倍",
    5 => "物品掉落几率双倍"
  }
  #伤害类型
  DAMAGE_TYPE = {
    0 => "无",
    1 => "体力值伤害",
    2 => "魔力值伤害",
    3 => "体力值恢复",
    4 => "魔力值恢复",
    5 => "体力值吸收",
    6 => "魔力值吸收"
  }
  #普通能力
  #这只是个示范，你也可以依照个人喜好对这些用语添加颜色控制符
  @params ={
    0 => "\\c[17]最大HP",
    1 => "\\c[16]最大MP",
    2 => "\\c[20]物攻",
    3 => "\\c[21]物防",
    4 => "\\c[30]魔攻",
    5 => "\\c[31]魔防",
    6 => "\\c[14]敏捷",
    7 => "\\c[17]幸运"
  }
  #我举例技能类型的原因就是因为它 短
  @skill_types = { # 这个和下面equiphelpready里注释掉的做的是一样的事
                   # 只是下面是读取数据库添加用语，这里是手动枚举
    1 => "\\c[1]特技",
    2 => "\\c[2]魔法",
    3 => "\\c[3]必杀",
    4 => "\\c[5]卖萌"
  }
end
#==============================================================================
# ☆ 设定完成 - END Setting ☆
#==============================================================================
module VIPArcher::Help_Ex
  #--------------------------------------------------------------------------
  # ● 读取数据库
  #       初始化数据,当然如果你要用上面那样的控制符改变颜色的话
  #       欢迎枚举,格式就是上面这样用Hash，用ID做键把用语对应起来
  #--------------------------------------------------------------------------
  def self.init_ready
    init_variable
    init_states
    init_params
    init_elements
    init_weapon_types
    init_armor_types
    init_skill_types
    init_etypes
  end
  #--------------------------------------------------------------------------
  # ● 初始化用语的实例变量
  #--------------------------------------------------------------------------
  def self.init_variable
    @states       ||= {}
    @params       ||= {}
    @weapon_types ||= {}
    @armor_types  ||= {}
    @etypes       ||= {}
    @skill_types  ||= {}
    @elements     ||= {}
  end
  #--------------------------------------------------------------------------
  # ● 读取状态名称
  #--------------------------------------------------------------------------
  def self.init_states
    return unless @states.empty?
    $data_states.each_with_index do |state,i|
      @states[i] = state.name unless state.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取能力用语
  #--------------------------------------------------------------------------
  def self.init_params
    return unless @params.empty?
    $data_system.terms.params.each_with_index do |param,i|
      @params[i] = param
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取属性名称用语
  #--------------------------------------------------------------------------
  def self.init_elements
    return unless @elements.empty?
    $data_system.elements.each_with_index do |element,i|
      @elements[i] = element unless element.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取武器类型用语
  #--------------------------------------------------------------------------
  def self.init_weapon_types
    return unless @weapon_types.empty?
    $data_system.weapon_types.each_with_index do |type,i|
      @weapon_types[i] = type unless type.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取防具类型用语
  #--------------------------------------------------------------------------
  def self.init_armor_types
    return unless @armor_types.empty?
    $data_system.armor_types.each_with_index do |type,i|
      @armor_types[i] = type unless type.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取技能类型用语
  #--------------------------------------------------------------------------
  def self.init_skill_types
    return unless @skill_types.empty?
    $data_system.skill_types.each_with_index do |type,i|
      @skill_types[i] = type unless type.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 读取装备位置用语
  #--------------------------------------------------------------------------
  def self.init_etypes
    return unless @etypes.empty?
    $data_system.terms.etypes.each_with_index do |type,i|
      @etypes[i] = type unless type.nil?
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取指定code的特性信息
  #--------------------------------------------------------------------------
  def self.select_features(item,code)
    item.features.select {|f| f.code == code}.each {|index| yield index }
  end
  #--------------------------------------------------------------------------
  # ● 获取指定code的使用效果信息
  #--------------------------------------------------------------------------
  def self.select_effects(item,code)
    item.effects.select {|e| e.code == code}.each {|index| yield index }
  end
  #--------------------------------------------------------------------------
  # ● 获取物品帮助说明
  #--------------------------------------------------------------------------
  def self.get_item_help(item)
    name(item) + description(item) + skill_cost(item) + occasion(item) + 
    price(item) + skill_speed(item) + success_rate(item) + item_type(item) + 
    damage_scope(item) + buff_params(item) + atk_states(item) +
    special_flag(item) + (item.is_a?(RPG::Skill) ? required_wtype(item) : "")
  end
  #--------------------------------------------------------------------------
  # ● 获取物品帮助说明
  #--------------------------------------------------------------------------
  def self.get_equip_help(equip)
    name(equip) + description(equip) + price(equip) + etype_id(equip) +
    exdrop(equip) + equip_limit(equip) + equip_param(equip) + equip_slot(equip) + 
    features_param(equip) + features_rate(equip) + state_attack(equip) + 
    equip_skill(equip) + flag_ability(equip)
  end
  #--------------------------------------------------------------------------
  # ● 获取物品技能名字
  #--------------------------------------------------------------------------
  def self.name(item)
    if $VIPArcherScript[:itemcolor] # require 物品描绘颜色脚本 by:VIPArcher
      "\\c[16]名称：\\c[#{VIPArcher::ItemColor::Color_Lv[item.color]}]" + 
      "#{item.name}  #{(item.color.to_s + "★") if item.color != 0}\\c[0]\n"
    else
      "\\c[16]名称：\\c[0]#{item.name}\n"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取物品技能背景说明
  #--------------------------------------------------------------------------
  def self.description(item)
    "\\c[16]介绍：\\c[0]#{item.description}\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品使用场合
  #--------------------------------------------------------------------------
  def self.occasion(item)
    return "" if item.occasion == 0
    "\\c[16]可用场合：#{OCCASION[item.occasion]}\\c[0]\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取物品价格信息
  #--------------------------------------------------------------------------
  def self.price(item)
    return "" if item.is_a?(RPG::Skill)
    price = item.price == 0 ? "\\c[14]无法出售\\c[0]" : item.price.to_s
    if $VIPArcherScript[:load]      # require 队伍负重脚本
      "\\c[16]售价：#{price} 重量：#{item.load}\\c[0]\n"
    else
      "\\c[16]售价：#{price}\\c[0]\n"
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取掉率扩展信息
  #--------------------------------------------------------------------------
  def self.exdrop(equip)
    return "" if equip.is_a?(RPG::Item)
    return "" unless $VIPArcherScript[:exdrop_rate]   # require 队伍掉率扩展
    equip.note =~ /<(\W+)掉率:\s*([0-9+.-]+)%>/i ? 
    "\\c[#{$2.to_i > 0 ? UP : DOWN}]#{$1}掉率: #{$2}%\\c[0]\n" : ""
  end
  #--------------------------------------------------------------------------
  # ● 获取装备能力限制数据 require 装备能力限制 by 后知后觉
  #--------------------------------------------------------------------------
  def self.equip_limit(equip)
    help = ""
    return help unless $VIPArcherScript[:equip_limit] #装备能力限制
    help += "\\c[16]等级需求：#{equip.level_limit}\n" if equip.level_limit > 0
    0..7.each do |i|
      if equip.params_limit(i) != 0
        help += "\\c[16]#{@params[i]}需求：#{equip.params_limit(i)}\\c[0]\n"
      end
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备能力附加值
  #--------------------------------------------------------------------------
  def self.equip_param(equip)
    help = ""
    equip.params.each_with_index do |param,i|
      value_color = "\\c[#{param > 0 ? UP : DOWN}]"
      value_string = "#{"+"if param > 0}#{param.to_int.to_s}\\c[0]\n"
      help += "#{@params[i]}: #{value_color}#{value_string}" if param != 0
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备风格信息 
  #--------------------------------------------------------------------------
  def self.equip_slot(equip)
    if $VIPArcherScript[:slot_type] # require 装备风格扩展 by VIPArcher
      equip.note =~ /<slot_type\s*[:](.*)>/i ?
      "\\c[#{VIP}]#{CODE[55]}：#{SLOT_TYPE[$1.to_i]}\\c[0]\n" : ""
    else
      equip.features.any? {|f|f.code == 55} ?
      "\\c[#{VIP}]#{CODE[55]}：双持武器\\c[0]\n" : ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取装备位置信息
  #--------------------------------------------------------------------------
  def self.etype_id(equip)
    "\\c[16]装备位置：\\c[0]#{Vocab::etype(equip.etype_id)}\\c[0]\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能装备限制
  #--------------------------------------------------------------------------
  def self.required_wtype(skill)
    w_1 = $data_system.weapon_types[skill.required_wtype_id1]
    w_2 = $data_system.weapon_types[skill.required_wtype_id2]
    (w_1 + w_2).empty? ? "" : "\\c[#{DOWN}]武器限制：#{w_1} #{w_2}\\c[0]\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能消耗信息
  #--------------------------------------------------------------------------
  def self.skill_cost(skill)
    return "" if skill.is_a?(RPG::Item)
    mp = skill.mp_cost > 0 ? "\\c[#{MP}]MP：#{skill.mp_cost}\\c[0]\n" : ""
    tp = skill.tp_cost > 0 ? "\\c[#{TP}]TP：#{skill.tp_cost}\\c[0]\n" : ""
    (mp + tp).empty? ? "" : "\\c[16]消耗：#{mp} #{tp}"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品速度修正
  #--------------------------------------------------------------------------
  def self.skill_speed(skill)
    return "" if skill.speed == 0
    "\\c[#{skill.speed < 0 ? DOWN : UP}]速度修正：#{skill.speed}\\c[0]\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品成功率
  #--------------------------------------------------------------------------
  def self.success_rate(skill)
    return "" if skill.success_rate == 100
    "\\c[#{DOWN}]成功率：#{skill.success_rate}％\\c[0]\n"
  end
  #--------------------------------------------------------------------------
  # ● 获取技能伤害类型或者物品类型
  #--------------------------------------------------------------------------
  def self.item_type(item)
    if item.is_a?(RPG::Skill)
      "\\c[16]伤害类型：#{HIT[item.hit_type]}\\c[0]\n"
    elsif item.is_a?(RPG::Item)
      "\\c[16]物品类型：\\c[#{VIP}]#{"贵重物品  " if item.itype_id != 1}" +
      "\\c[#{DOWN}]#{item.consumable ? "消耗品" : "非消耗品"}\\c[0]\n"
    else ; ""
    end
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品效果范围
  #--------------------------------------------------------------------------
  def self.damage_scope(item)
    scope = item.scope == 0 ? "" : "\\c[16]范围：#{SCOPE[item.scope]}\\c[0]\n"
    type,id = DAMAGE_TYPE[item.damage.type],@elements[item.damage.element_id]
    damage = item.damage.type == 0 ? "" : "\\c[16]效果：#{id}#{type}\\c[0]\n"
    scope + damage
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品强化弱化效果
  #--------------------------------------------------------------------------
  def self.buff_params(item)
    help = ""
    select_effects(item,31) do |e|
      help += "\\c[#{UP}]强化：#{@params[e.data_id]} #{e.value1.to_i}回合\\c[0]\n"
    end
    select_effects(item,32) do |e|
      help += "\\c[#{UP}]弱化：#{@params[e.data_id]} #{e.value1.to_i}回合\\c[0]\n"
    end
    select_effects(item,33) do |e|
      help += "\\c[#{UP}]解除：强化#{@params[e.data_id]}\\c[0]\n"
    end
    select_effects(item,34) do |e|
      help += "\\c[#{UP}]解除：弱化#{@params[e.data_id]}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品附加移除状态
  #--------------------------------------------------------------------------
  def self.atk_states(item)
    help = ""
    select_effects(item,21) do |e|
      state = e.data_id == 0 ? "普通攻击" : @states[e.data_id]
      help += "\\c[#{UP}]附加：#{state} #{(e.value1*100).to_i}%\\c[0]\n"
    end
    select_effects(item,22) do |e|
      help += "\\c[#{UP}]解除：#{@states[e.data_id]} #{(e.value1 * 100).to_i}%\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取技能物品特殊效果内容
  #--------------------------------------------------------------------------
  def self.special_flag(item)
    help = ""
    select_effects(item,41) {|e| help += "\\c[#{VIP}]特殊效果：撤退\\c[0]\n"}
    select_effects(item,42) do |e|
      help += "\\c[#{UP}]提升：#{@params[e.data_id]}#{e.value1.to_i}点\\c[0]\n"
    end
    select_effects(item,43) do |e|
      help += "\\c[#{VIP}]学会：#{$data_skills[e.data_id].name}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备特性能力值
  #--------------------------------------------------------------------------
  def self.features_param(equip)
    help = ""
    equip.features.each do |f|
      value = "#{f.value < 0 ? "﹣" : "﹢"}#{(f.value.abs*100).to_i}％\\c[0]"
      params = case f.code
      when 21 then @params[f.data_id]
      when 22,23 then XPARAM[f.data_id]
      else ; next ; end
      help += "\\c[#{f.value < 0 ? DOWN : UP}]#{params}#{value}\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备状态抗性
  #--------------------------------------------------------------------------
  def self.features_rate(equip)
    help = ""
    equip.features.each do |f|
      name,value = "#{CODE[f.code]}：","#{(f.value*100).to_i}％\\c[0]"
      params = case f.code
      when 11 then @elements[f.data_id]
      when 12 then @params[f.data_id]
      when 13 then @states[f.data_id]
      when 14 
        help += "\\c[#{VIP}]#{name}#{@states[f.data_id]}\\c[0]\n" ; next
      else ; next ; end
      help += "\\c[#{UP}]#{name}#{params}×#{value}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加状态攻击效果
  #--------------------------------------------------------------------------
  def self.state_attack(equip)
    help = ""
    equip.features.each do |f|
      text = case f.code
      when 31 then "#{@elements[f.data_id]}"
      when 32 then "#{@states[f.data_id]}#{(f.value * 100).to_i}％"
      when 34 then help += "\\c[#{UP}]#{CODE[f.code]}：#{f.value}\\c[0]\n" ; next
      when 33 then color = f.value > 0 ? UP : DOWN
        help += "\\c[#{color}]#{CODE[f.code]}：#{f.value}\\c[0]\n" ; next
      else ; next ; end
      help += "\\c[#{UP}]#{CODE[f.code]}：#{text}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备附加装备效果技能
  #--------------------------------------------------------------------------
  def self.equip_skill(equip)
    help = ""
    if $VIPArcherScript[:slot_type]       # require 装备风格扩展 by VIPArcher
      equip.note.split(/[\r\n]+/).each do |line|
        help += line =~ /<fix_equips\s*[:](\d+)>/i ?
        "\\c[#{DOWN}]#{CODE[53]}：#{Vocab.etype($1.to_i)}\\c[0]\n" : ""
        help += line =~ /<seal_equips\s*[:](\d+)>/i ?
        "\\c[#{DOWN}]#{CODE[54]}：#{Vocab.etype($1.to_i)}\\c[0]\n" : ""
      end
    end
    equip.features.each do |f|
      text = case f.code
      when 41,42 then "#{CODE[f.code]}：#{@skill_types[f.data_id]}"
      when 43,44 then "#{CODE[f.code]}：#{$data_skills[f.data_id].name}"
      when 51
        help += "\\c[#{UP}]#{CODE[f.code]}：#{@weapon_types[f.data_id]}\\c[0]\n" ; next
      when 52 
        help += "\\c[#{UP}]#{CODE[f.code]}：#{@armor_types[f.data_id]}\\c[0]\n" ; next
      when 53,54
        help += "\\c[#{DOWN}]#{CODE[f.code]}：#{@etypes[f.data_id]}\\c[0]\n" ; next
      else ; next ; end
      help += "\\c[#{f.code % 2 == 0 ? DOWN : UP}]#{text}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 获取装备标志和队伍能力
  #--------------------------------------------------------------------------
  def self.flag_ability(equip)
    help = ""
    equip.features.each do |f|
      flag_party = case f.code
      when 61
        help += "\\c[#{VIP}]#{CODE[f.code]}：#{(f.value * 100).to_i}％\\c[0]\n" ; next
      when 62 then FLAG[f.data_id]
      when 64 then PARTY_ABILITY[f.data_id]
      else ; next ; end
      help += "\\c[#{VIP}]#{CODE[f.code]}：#{flag_party}\\c[0]\n"
    end ; help
  end
  #--------------------------------------------------------------------------
  # ● 计算行数  有些字体的汉字和[字母,数字,符号]的宽度不同，
  #             有可能会照成行数计算不对，尽量用宽度相同的字体吧
  #--------------------------------------------------------------------------
  def self.get_line(text,max_size)
    xtext,line,text_new = [],0,""
    text.each_line{|x| text_new += x.gsub(/\\\S\[\d+\]/i){}} #去掉控制符
    text_new.each_line{|x| xtext.push x.gsub(/\n/){}} #去掉换行符
    xtext.each{|x| line += (x.size / (max_size.to_f + 1).to_i) + 1}
    line
  end
end
#==============================================================================
# ■ Window_Help_Ex
#------------------------------------------------------------------------------
# 　加强显示特技和物品等的说明
#==============================================================================
class Window_Help_Ex < Window_Help
  include VIPArcher
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(0) ; self.viewport ,self.width ,self.height = viewport ,210 ,0
    contents.font.size ,self.z ,@time = 14 ,150 ,0
  end
  #--------------------------------------------------------------------------
  # ● ***********计算窗口显示指定行数时的应用高度(适应字体大小)***********
  #--------------------------------------------------------------------------
  def fitting_height_vip(line_number)
    line_number * contents.font.size + standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # ● 绘制带有控制符的文本内容
  #   如果传递了width参数的话，会自动换行
  #   draw_text_ex的增强，使其可以自动换行  原作者：叶子 修改：wyongcan
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text, width = nil,text_width = nil,normalfont = true)
    reset_font_settings if normalfont == true
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    unless width.nil?
      pos[:height],pos[:width],pos[:text_width] = contents.font.size,width,text_width
    end
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # ● 文字的处理
  #     c    : 文字
  #     text : 绘制处理中的字符串缓存（字符串可能会被修改）
  #     pos  : 绘制位置 {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    super(c, text, pos)
    text_width = pos[:text_width].nil? ? text_size(c).width : pos[:text_width]
    process_new_line(text, pos) if pos[:width] != nil &&
    pos[:x] - pos[:new_x] + text_width > pos[:width]
  end
  #--------------------------------------------------------------------------
  # ● 处理换行文字
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    super(text, pos)
    pos[:height] = contents.font.size unless pos[:width].nil?
  end
  #--------------------------------------------------------------------------
  # ● 设置内容
  #--------------------------------------------------------------------------
  def set_text(text)
    @text = text if text != @text
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助位置
  #--------------------------------------------------------------------------
  def uppos(index,rect,window)
    self.height = fitting_height_vip(Help_Ex.get_line(@text,13))
    create_contents
    contents.font.name,contents.font.size = Help_Ex::Font_Name,Help_Ex::Font_Size
    rect.x -= window.ox ; rect.y -= window.oy
    ax = rect.x + rect.width + 10
    ax = rect.x - self.width + 10 if ax + self.width > window.width + 10
    ax = 0 if ax < 0 ; ay = rect.y + rect.height
    ay = rect.y - self.height if ay + self.height > window.height
    ax += window.x ; ay += window.y
    ay = 0 if ay < 0 ; self.show
    self.x , self.y , self.openness, @time = ax , ay , 0 , Help_Ex::TIME
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #     item : 技能、物品等
  #--------------------------------------------------------------------------
  def set_item(item)
    return self.hide unless item ; text = ""
    text += if item.is_a?(RPG::EquipItem) then Help_Ex.get_equip_help(item)
    else ; Help_Ex.get_item_help(item) ; end
    text = text[0,text.size - 2] if text[text.size - 2,2] == "\n"
    set_text(text)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh 
    contents.clear
    self.hide if @text == ""
    draw_text_ex(4, 0, @text,width,40,false)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super ; @time -= 1 if @time > 0 ; self.open if @time == 0
  end
end
#==============================================================================
# ■ 设置帮助增强窗口
#==============================================================================
class Window_Selectable < Window_Base
  attr_reader   :help_ex_window
  #--------------------------------------------------------------------------
  # ● 调用帮助窗口的更新方法
  #--------------------------------------------------------------------------
  alias help_ex_call_update_help call_update_help
  def call_update_help
    help_ex_call_update_help ; update_ex_help if active && @help_ex_window
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助内容
  #--------------------------------------------------------------------------
  def update_ex_help
    @help_ex_window.set_item(item) if @help_ex_window
    @help_ex_window.uppos(index,item_rect(index),self) if index != -1 && item
  end
  #--------------------------------------------------------------------------
  # ● 设置帮助增强窗口
  #--------------------------------------------------------------------------
  def help_ex_window=(help_ex_window)
    @help_ex_window = help_ex_window
  end
end
#==============================================================================
# ■ 在各场景处理帮助窗口
#==============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # ● 生成帮助增强窗口
  #--------------------------------------------------------------------------
  def create_help_ex
    @help_ex_window  = Window_Help_Ex.new(@viewport)
    @item_window.help_ex_window  = @help_ex_window if @item_window
    @slot_window.help_ex_window  = @help_ex_window if @slot_window
    @skill_window.help_ex_window = @help_ex_window if @skill_window
    @buy_window.help_ex_window   = @help_ex_window if @buy_window
    @sell_window.help_ex_window  = @help_ex_window if @sell_window
  end
end
#道具栏
class Scene_Item < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start ; create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel ; @help_ex_window.hide
  end
end
#装备栏
class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start ; create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 装备栏“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_slot_cancel on_slot_cancel
  def on_slot_cancel
    help_ex_on_slot_cancel ; @help_ex_window.hide
  end
end
#技能栏
class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start ; create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_ok on_item_ok
  def on_item_ok
    help_ex_on_item_ok ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel ; @help_ex_window.hide
  end
end
#战斗界面
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start ; create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 技能“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_skill_ok on_skill_ok
  def on_skill_ok
    help_ex_on_skill_ok ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 技能“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_skill_cancel on_skill_cancel
  def on_skill_cancel
    help_ex_on_skill_cancel ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_ok on_item_ok
  def on_item_ok
    help_ex_on_item_ok ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel ; @help_ex_window.hide
  end
end
#商店界面
class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start ; create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 买入“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_buy_ok on_buy_ok
  def on_buy_ok
    help_ex_on_buy_ok ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 买入“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_buy_cancel on_buy_cancel
  def on_buy_cancel
    help_ex_on_buy_cancel ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 卖出“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_sell_ok on_sell_ok
  def on_sell_ok
    help_ex_on_sell_ok ; @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 卖出“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_sell_cancel on_sell_cancel
  def on_sell_cancel
    help_ex_on_sell_cancel ; @help_ex_window.hide
  end
end
#==============================================================================
# ★ 脚本顺序检查 ★
#==============================================================================
msgbox "物品描绘颜色脚本需置于物品帮助增强脚本之下" if $VIPArcherScript[:itemcolor] &&
  $VIPArcherScript[:help_ex] > $VIPArcherScript[:itemcolor]
msgbox "队伍掉率扩展脚本需置于物品帮助增强脚本之下" if $VIPArcherScript[:exdrop_rate] &&
  $VIPArcherScript[:help_ex] > $VIPArcherScript[:exdrop_rate]
msgbox "装备风格扩展脚本需置于物品帮助增强脚本之下" if $VIPArcherScript[:slot_type] &&
  $VIPArcherScript[:help_ex] > $VIPArcherScript[:slot_type]
msgbox "队伍负重脚本需置于物品帮助增强脚本之下" if $VIPArcherScript[:load] &&
  $VIPArcherScript[:help_ex] > $VIPArcherScript[:load]