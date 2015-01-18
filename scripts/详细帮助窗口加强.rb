#encoding:utf-8
#==============================================================================
# ■ 技能物品说明增强 蓝本：wyongcan
# 修改 ：VIPArcher
#
# 改动说明：
# [删除线]old_xxx这种别名方法到底是从哪里开始流传的啊？[/删除线]
# 改用新的帮助窗口和新定义draw_text_vip方法来增强兼容性
# 更改初始化数据时机以支持跳过标题
# 追加对普通物品和技能的说明内容
# 修改了对帮助窗口行数的计算以支持控制符
# 加上了各种颜色的设置，具体更高级的玩法自己领悟吧
# 改成光标不动一段时间后才会出现帮助窗口
#
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:help_ex] = 20141007
$VIPArcherScript[:equip_limit] = false #是否使用了后知后觉的装备能力限制
class << DataManager
  alias_method :vip_load_database, :load_database
  #--------------------------------------------------------------------------
  # ● 读取数据库
  #--------------------------------------------------------------------------
  def load_database
    vip_load_database
    VIPArcher::Equipplus.equiphelpready
  end
end
module VIPArcher end
module VIPArcher::Equipplus
  TIME = 90 #帮助窗口自动出现的时间（单位帧
  Font_Name = Font.default_name # 推荐"微软雅黑"
  Font_Size = 14                # "微软雅黑"的话就20号字体
  UP   = 24 #能力值提升颜色编号
  DOWN = 25 #能力值下降颜色编号
  VIP  = 14 #特殊能力颜色编号
  MP   = 23
  TP   = 29
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
    64 => "队伍能力"}
  #特殊标志
  FLAG ={
    0 => "自动战斗",
    1 => "擅长防御",
    2 => "保护弱者",
    3 => "特技专注"}
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
    11 => "使用者" }
  #技能命中类型
  HIT ={
    0 => "必定命中",
    1 => "物理攻击",
    2 => "魔法攻击"}
  #使用限制
  OCCASION ={
    0 => "随时可用",
    1 => "仅战斗中",
    2 => "仅菜单中",
    3 => "不能使用"}
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
    9 => "特技值再生速度："}
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
    9 => "经验获得加成"}
  #装备风格  require 装备风格扩展脚本
  SLOT_TYPE ={
    0 => "普通",
    1 => "双持武器",
    2 => "索爷三刀流",
    3 => "NPC",
    4 => "233",
    5 => "论坛@的BUG好烦啊"}
  #队伍能力
  PARTY_ABILITY ={
    0 => "遇敌几率减半",
    1 => "随机遇敌无效",
    2 => "敌人偷袭无效",
    3 => "先制攻击几率上升",
    4 => "获得金钱数量双倍",
    5 => "物品掉落几率双倍"}
  #伤害类型
  DAMAGE_TYPE = {
    0 => "无",
    1 => "体力值伤害",
    2 => "魔力值伤害",
    3 => "体力值恢复",
    4 => "魔力值恢复",
    5 => "体力值吸收",
    6 => "魔力值吸收"}
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
    7 => "\\c[17]幸运"}
  #我举例技能类型的原因就是因为它 短
  @skill_types = { # 这个和下面equiphelpready里注释掉的做的是一样的事
                   # 只是下面是读取数据库添加用语，这里是手动枚举
    1 => "\\c[1]特技",
    2 => "\\c[2]魔法",
    3 => "\\c[3]必杀",
    4 => "\\c[5]卖萌"}
  #初始化数据,当然如果你要用上面那样的控制符改变颜色的话
  #欢迎枚举格式就是上面这样用Hash，用ID做键把用语对应起来
  def self.equiphelpready
    params = $data_system.terms.params
    elements = $data_system.elements
    weapon_types = $data_system.weapon_types
    armor_types = $data_system.armor_types
    etypes = $data_system.terms.etypes
    skill_types = $data_system.skill_types
    @states       ||= {}
    @params       ||= {}
    @weapon_types ||= {}
    @armor_types  ||= {}
    @etypes       ||= {}
    @skill_types  ||= {}
    @elements     ||= {}
    skill_types.each_with_index{|x,y| @skill_types[y] = x if !x.nil?} if @skill_types == {}
    $data_states.each{|x| @states[x.id] = x.name if !x.nil?} if @states == {}
    elements.each_with_index{|x,y| @elements[y] = x if !x.nil?} if @elements == {}
    weapon_types.each_with_index{|x,y| @weapon_types[y] = x if !x.nil?} if @weapon_types == {}
    armor_types.each_with_index{|x,y| @armor_types[y] = x if !x.nil?} if @armor_types == {}
    etypes.each_with_index{|x,y| @etypes[y] = x} if @etypes == {}
    params.each_with_index{|x,y| @params[y] = x} if @params == {}
  end
  #获取装备帮助内容
  def self.getequiphelp(equip)
    help = ""
    param = []
    help += "\\c[16]装备位置：#{Vocab::etype(equip.etype_id)}\\c[0]\n"
    if $VIPArcherScript[:equip_limit] #装备能力限制
      help += "\\c[16]等级需求：#{equip.level_limit}\n" if equip.level_limit > 0
      param_limit = []
      for i in 0..7
        if equip.params_limit(i) != 0
          help += "\\c[16]#{@params[i]}需求：#{equip.params_limit(i)}\\c[0]\n"
        end
      end
    end
    equip.params.each_with_index{|x,y| param.push([@params[y],x])}
    param = param.select{|x| x[1] != 0}
    param.each{|x| help += "\\c[#{x[1]>0? UP : DOWN}]#{x[0]}：\\c[#{x[1]>0? UP : DOWN}]#{"﹢"if x[1]>0}#{x[1].to_int.to_s}\\c[0]\n"}
    features = equip.features
    featuresparam = []
    featuresparam.push features.select{|x| x.code == 21}
    featuresparam.push features.select{|x| x.code == 22}
    featuresparam.push features.select{|x| x.code == 23}
    featuresparam[0].each{|x| help += "\\c[#{x.value<0?DOWN: UP}]#{@params[x.data_id]}#{x.value<0?"﹣":"﹢"}#{(x.value.abs*100).to_i}％\n"}
    featuresparam[1].each{|x| help += "\\c[#{x.value<0?DOWN: UP}]#{XPARAM[x.data_id]}#{x.value<0?"﹣":"﹢"}#{(x.value.abs*100).to_i}％\n"}
    featuresparam[2].each{|x| help += "\\c[#{x.value<0?DOWN: UP}]#{SPARAM[x.data_id]}#{x.value<0?"﹣":"﹢"}#{(x.value.abs*100).to_i}％\n"}
    if $VIPArcherScript[:slot_type]
      help += "\\c[#{VIP}]#{CODE[55]}：#{SLOT_TYPE[$1.to_i]}\\c[0]\n" if equip.note =~ /<slot_type\s*[:](.*)>/i
    else
      features.select{|x| x.code == 55}.each{|x| help += "\\c[#{VIP}]#{CODE[x.code]}：双持武器\\c[0]\n"}
    end
    features.select{|x| x.code == 11}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@elements[x.data_id]}×#{(x.value*100).to_i}％\\c[0]\n"}
    features.select{|x| x.code == 12}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@params[x.data_id]}×#{(x.value*100).to_i}％\\c[0]\n"}
    features.select{|x| x.code == 13}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@states[x.data_id]}×#{(x.value*100).to_i}％\\c[0]\n"}
    features.select{|x| x.code == 14}.each{|x| help += "\\c[#{VIP}]#{CODE[x.code]}：#{@states[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 31}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@elements[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 32}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@states[x.data_id]}#{(x.value*100).to_i}％\\c[0]\n"}
    features.select{|x| x.code == 33}.each{|x| help += "\\c[#{x.value>0? UP : DOWN}]#{CODE[x.code]}：#{x.value}\\c[0]\n"}
    features.select{|x| x.code == 34}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{x.value}\\c[0]\n"}
    features.select{|x| x.code == 41}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@skill_types[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 42}.each{|x| help += "\\c[#{DOWN}]#{CODE[x.code]}：#{@skill_types[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 43}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{$data_skills[x.data_id].name}\\c[0]\n"}
    features.select{|x| x.code == 44}.each{|x| help += "\\c[#{DOWN}]#{CODE[x.code]}：#{$data_skills[x.data_id].name}\\c[0]\n"}
    features.select{|x| x.code == 51}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@weapon_types[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 52}.each{|x| help += "\\c[#{UP}]#{CODE[x.code]}：#{@armor_types[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 53}.each{|x| help += "\\c[#{DOWN}]#{CODE[x.code]}：#{@etypes[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 54}.each{|x| help += "\\c[#{DOWN}]#{CODE[x.code]}：#{@etypes[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 61}.each{|x| help += "\\c[#{VIP}]#{CODE[x.code]}：#{x.value}\\c[0]\n"}
    features.select{|x| x.code == 62}.each{|x| help += "\\c[#{VIP}]#{CODE[x.code]}：#{FLAG[x.data_id]}\\c[0]\n"}
    features.select{|x| x.code == 64}.each{|x| help += "\\c[#{VIP}]#{CODE[x.code]}：#{PARTY_ABILITY[x.data_id]}\\c[0]\n"}
    help
  end
  #获取技能帮助内容
  def self.getskillhelp(skill)
    help = ""
    effects = skill.effects
    damage  = skill.damage
    r = [skill.required_wtype_id1,skill.required_wtype_id2]
    help += "\\c[16]消耗：\\c[#{MP}]MP：#{skill.mp_cost.to_s} \\c[#{TP}]TP：#{skill.tp_cost.to_s}\\c[0]\n" if skill.mp_cost > 0 && skill.tp_cost > 0
    help += "\\c[16]消耗：\\c[#{MP}]MP：#{skill.mp_cost.to_s}\\c[0]\n" if skill.mp_cost > 0 && skill.tp_cost <= 0
    help += "\\c[16]消耗：\\c[#{TP}]TP：#{skill.tp_cost.to_s}\\c[0]\n" if skill.tp_cost > 0 && skill.mp_cost <= 0
    help += "\\c[#{skill.speed<0?DOWN: UP}]速度修正：#{skill.speed}\\c[0]\n" if skill.speed != 0
    help += "\\c[#{DOWN}]成功率：#{skill.success_rate}％\\c[0]\n" if skill.success_rate != 100
    help += "\\c[16]类型：#{HIT[skill.hit_type]}\\c[0]\n"
    help += "\\c[16]范围：#{SCOPE[skill.scope]}\\c[0]\n" if skill.scope != 0
    help += "\\c[16]效果：#{@elements[damage.element_id]}#{DAMAGE_TYPE[damage.type]}\\c[0]\n" if damage.type != 0
    effects.select{|x| x.code == 31}.each{|x| help += "\\c[#{UP}]强化：#{@params[x.data_id]} #{x.value1.to_i}回合\\c[0]\n"}
    effects.select{|x| x.code == 32}.each{|x| help += "\\c[#{UP}]弱化：#{@params[x.data_id]} #{x.value1.to_i}回合\\c[0]\n"}
    effects.select{|x| x.code == 33}.each{|x| help += "\\c[#{UP}]解除：强化#{@params[x.data_id]}\n"}
    effects.select{|x| x.code == 34}.each{|x| help += "\\c[#{UP}]解除：弱化#{@params[x.data_id]}\n"}
    effects.select{|x| x.code == 21}.each{|x| help += "\\c[#{UP}]附加：#{x.data_id == 0 ? "普通攻击" : @states[x.data_id]} #{(x.value1*100).to_i}%\\c[0]\n"}
    effects.select{|x| x.code == 22}.each{|x| help += "\\c[#{UP}]解除：#{@states[x.data_id]} #{(x.value1*100).to_i}%\\c[0]\n"}
    effects.select{|x| x.code == 41}.each{|x| help += "\\c[#{VIP}]特殊效果：撤退\n"}
    effects.select{|x| x.code == 42}.each{|x| help += "\\c[#{UP}]提升：#{@params[x.data_id]}#{x.value1.to_i}点\\c[0]\n"}
    effects.select{|x| x.code == 43}.each{|x| help += "\\c[#{VIP}]学会：#{$data_skills[x.data_id].name}\\c[0]\n"}
    help += "\\c[16]场合：#{OCCASION[skill.occasion]}\n"
    help += "\\c[#{DOWN}]限制：#{$data_system.weapon_types[r[0]] if r[0] != 0} #{$data_system.weapon_types[r[1]] if r[1] != 0}\\c[0]\n" if r != [0,0]
    help
  end
  #获取道具帮助内容
  def self.getitemhelp(item)
    help = ""
    effects = item.effects
    damage  = item.damage
    help += "\\c[16]类型：\\c[#{VIP}]#{"贵重物品  "if item.itype_id != 1}\\c[#{DOWN}]#{item.consumable ? "消耗品":"非消耗品"}\\c[0]\n"
    help += "\\c[16]范围：#{SCOPE[item.scope]}\\c[0]\n" if item.scope != 0
    help += "\\c[16]效果：#{@elements[damage.element_id]}#{DAMAGE_TYPE[damage.type]}\\c[0]\n" if damage.type != 0
    effects.select{|x| x.code == 31}.each{|x| help += "\\c[#{UP}]强化：#{@params[x.data_id]} #{x.value1.to_i}回合\\c[0]\n"}
    effects.select{|x| x.code == 32}.each{|x| help += "\\c[#{UP}]弱化：#{@params[x.data_id]} #{x.value1.to_i}回合\\c[0]\n"}
    effects.select{|x| x.code == 33}.each{|x| help += "\\c[#{UP}]解除：强化#{@params[x.data_id]}\\c[0]\n"}
    effects.select{|x| x.code == 34}.each{|x| help += "\\c[#{UP}]解除：弱化#{@params[x.data_id]}\\c[0]\n"}
    effects.select{|x| x.code == 21}.each{|x| help += "\\c[#{UP}]附加：#{x.data_id == 0 ? "普通攻击" : @states[x.data_id]} #{(x.value1*100).to_i}%\\c[0]\n"}
    effects.select{|x| x.code == 22}.each{|x| help += "\\c[#{UP}]解除：#{@states[x.data_id]} #{(x.value1*100).to_i}%\\c[0]\n"}
    effects.select{|x| x.code == 41}.each{|x| help += "\\c[#{VIP}]特殊效果：撤退\n"}
    effects.select{|x| x.code == 42}.each{|x| help += "\\c[#{VIP}]提升：#{@params[x.data_id]}#{x.value1.to_i}点\\c[0]\n"}
    effects.select{|x| x.code == 43}.each{|x| help += "\\c[#{VIP}]学会：#{$data_items[x.data_id].name}\\c[0]\n"}
    help += "\\c[16]场合：#{OCCASION[item.occasion]}\\c[0]\n"
    help
  end
  #计算行数（有些字体的汉字和[字母,数字,符号]的宽度不同，
  #有可能会照成行数计算不对，尽量用宽度相同的字体吧）
  def self.getline(text,maxtext)
    text_new = ""
    xtext = []
    line = 0
    text.each_line{|x| text_new += x.gsub(/\\\S\[\d+\]/i){}} #去掉控制符
    text_new.each_line{|x| xtext.push x.gsub(/\n/){}}        #去掉换行符
    xtext.each{|x| line += (x.size / (maxtext.to_f + 1).to_i) + 1}
    line
  end
end
#==============================================================================
# ■ Window_Help_Ex
#------------------------------------------------------------------------------
# 　加强显示特技和物品等的说明
#==============================================================================
 
class Window_Help_Ex < Window_Base
  include VIPArcher::Equipplus
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(line_number = 0)
    super(0, 0, 210, 0)
    self.z = 150
    contents.font.size = 14
    @time = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置内容
  #--------------------------------------------------------------------------
  def set_text(text)
    @text = text
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 清除
  #--------------------------------------------------------------------------
  def clear
    set_text("")
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助位置
  #--------------------------------------------------------------------------
  def uppos(index,rect,window)
    self.height = fitting_height_vip(VIPArcher::Equipplus.getline(@xtext,13))
    create_contents
    contents.font.name = Font_Name
    contents.font.size = Font_Size
    rect.x -= window.ox
    rect.y -= window.oy
    ax = rect.x + rect.width + 10
    ax = rect.x - self.width + 10 if ax + self.width > window.width + 10
    ax += window.x
    ax = 0 if ax < 0
    ay = rect.y + rect.height
    ay = rect.y - self.height if ay + self.height > window.height
    ay += window.y
    ay = 0 if ay < 0
    self.x = ax
    self.y = ay
    set_text(@xtext)
    @time = TIME
    self.show
    self.openness = 0
  end
  #--------------------------------------------------------------------------
  # ● 设置物品
  #     item : 技能、物品等
  #--------------------------------------------------------------------------
  def set_item(item)
    if item == nil
      set_text("")
      return
    end
    @xtext = ""
    if $VIPArcherScript[:itemcolor] # require 物品描绘颜色脚本
      @xtext = "\\c[16]名称：\\c[#{VIPArcher::ItemColor::Color_Lv[item.color]}]" +
      "#{item.name}  #{item.color if item.color != 0}#{"★" if item.color != 0}\\c[0]\n"
    else
      @xtext = "\\c[16]名称：\\c[0]#{item.name}\n"
    end
    @xtext += "\\c[16]介绍：\\c[0]#{item.description}\n"
    if $VIPArcherScript[:load]      # require 队伍负重脚本
      @xtext += "\\c[16]售价：#{item.price} 重量：#{item.load}\\c[0]\n"
    else
      @xtext += item.price == 0 ? "\\c[16]售价：\\c[14]无法出售\\c[0]\n":"\\c[16]售价：#{item.price}\\c[0]\n"
    end if item.is_a?(RPG::EquipItem) || item.is_a?(RPG::Item)
    @xtext += VIPArcher::Equipplus.getequiphelp(item) if item.is_a?(RPG::EquipItem)
    @xtext += VIPArcher::Equipplus.getskillhelp(item) if item.is_a?(RPG::Skill)
    @xtext += VIPArcher::Equipplus.getitemhelp(item) if item.is_a?(RPG::Item)
    if $VIPArcherScript[:exdrop_rate]   # require 队伍掉率扩展
      @xtext += "\\c[#{$2.to_i > 0 ? UP : DOWN}]#{$1}掉率: #{$2}%\\c[0]\n" if
      item.note =~ /<(\W+)掉率:\s*([0-9+.-]+)%>/i
    end if item.is_a?(RPG::EquipItem) || item.is_a?(RPG::Skill)
    @xtext = @xtext[0,@text.size - 2] if @xtext[@xtext.size - 2,2] == "\n"
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    self.hide if @text == ""
    draw_text_vip(4, 0, @text,width,40,false)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    @time -= 1 if @time > 0
    self.open if @time == 0
  end
end
class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 计算窗口显示指定行数时的应用高度2*************************
  #--------------------------------------------------------------------------
  def fitting_height_vip(line_number)
    line_number * contents.font.size + standard_padding * 2
  end
  # draw_text_ex的增强，使其可以自动换行  原作者：叶子 修改：wyongcan
  #--------------------------------------------------------------------------
  # ● 绘制带有控制符的文本内容
  #   如果传递了width参数的话，会自动换行
  #--------------------------------------------------------------------------
  def draw_text_vip(x, y, text, width = nil,textwidth = nil,normalfont = true)
    reset_font_settings if normalfont == true
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    if width != nil
      pos[:height] = contents.font.size
      pos[:width] = width
      pos[:textwidth] = textwidth
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
    case c
    when "\r"   # 回车
      return
    when "\n"   # 换行
      process_new_line(text, pos)
    when "\f"   # 翻页
      process_new_page(text, pos)
    when "\e"   # 控制符
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # 普通文字
      pos[:textwidth] == nil ? text_width = text_size(c).width : text_width = pos[:textwidth]
      if pos[:width] != nil && pos[:x] - pos[:new_x] + text_width > pos[:width]
        process_new_line(text, pos)
      end
      process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理换行文字
  #--------------------------------------------------------------------------
  alias vip_20141007_process_new_line process_new_line
  def process_new_line(text, pos)
    vip_20141007_process_new_line(text, pos)
    pos[:height] = contents.font.size if pos[:width] != nil
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
    help_ex_call_update_help
    update_ex_help if active && @help_ex_window
  end
  #--------------------------------------------------------------------------
  # ● 更新帮助内容
  #--------------------------------------------------------------------------
  def update_ex_help
    @help_ex_window.set_item(item) if @help_ex_window
    if index != -1 && item != nil
      @help_ex_window.uppos(index,item_rect(index),self)
    end
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
    @help_ex_window  = Window_Help_Ex.new
    @help_ex_window .viewport = @viewport
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
    help_ex_start
    create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel
    @help_ex_window.hide
  end
end
#装备栏
class Scene_Equip < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start
    create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 装备栏“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_slot_cancel on_slot_cancel
  def on_slot_cancel
    help_ex_on_slot_cancel
    @help_ex_window.hide
  end
end
#技能栏
class Scene_Skill < Scene_ItemBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start
    create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_ok on_item_ok
  def on_item_ok
    help_ex_on_item_ok
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel
    @help_ex_window.hide
  end
end
#战斗界面
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start
    create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 技能“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_skill_ok on_skill_ok
  def on_skill_ok
    help_ex_on_skill_ok
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 技能“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_skill_cancel on_skill_cancel
  def on_skill_cancel
    help_ex_on_skill_cancel
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_ok on_item_ok
  def on_item_ok
    help_ex_on_item_ok
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 物品“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_item_cancel on_item_cancel
  def on_item_cancel
    help_ex_on_item_cancel
    @help_ex_window.hide
  end
end
#商店界面
class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias help_ex_start start
  def start
    help_ex_start
    create_help_ex
  end
  #--------------------------------------------------------------------------
  # ● 买入“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_buy_ok on_buy_ok
  def on_buy_ok
    help_ex_on_buy_ok
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 买入“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_buy_cancel on_buy_cancel
  def on_buy_cancel
    help_ex_on_buy_cancel
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 卖出“确定”
  #--------------------------------------------------------------------------
  alias help_ex_on_sell_ok on_sell_ok
  def on_sell_ok
    help_ex_on_sell_ok
    @help_ex_window.hide
  end
  #--------------------------------------------------------------------------
  # ● 卖出“取消”
  #--------------------------------------------------------------------------
  alias help_ex_on_sell_cancel on_sell_cancel
  def on_sell_cancel
    help_ex_on_sell_cancel
    @help_ex_window.hide
  end
end