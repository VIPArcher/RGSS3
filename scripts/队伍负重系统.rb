#==============================================================================
# +++ VX移植 - VA负重系统改进版 +++
#==============================================================================
# VX版 原作者 By 雪流星
# 蓝本 杂兵天下的VA移植版
# 改进 By：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 物品备注<load N> 则该物品占用 N 点负重
# load也可以写成「负重」或「負重」#注：没有“「」”
# 不写的话默认为 Default_Load
# 更改当前负重可以对 $game_party.current_load 进行加，减，赋值
# 例如：$game_party.current_load += 1 #当前物品总重量加 1
# 默认给物品增加一行说明.说明内容是物品的重量. 但默认帮助窗口一共只能显示2行内容.
# 因此你在设置帮助说明的时候. 如果设置了2行内容. 那么这新增加的第3行将无法显示出来.
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:load] = 20140919
#-------------------------------------------------------------------------------
module  VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module  VIPArcher::Load
  Default_Load = 1    # 物品的默认负重
  Width = 150         # 负重信息窗口宽度
  Load_Name = "负重:" # 负重前显示的文字
  Load_Var = 0        # 作为队伍负重上限的变量ID，为0禁用变量作为负重上限，
                      # 计算方式变成累计每个角色的负重能力来计算负重上限。
  Load_Eval = "((mhp + mmp) / agi) * [hp_rate,0.5].max"
  # 每个角色的负重计算公式（eval）
  
  Stop_SW = false       # true 使用 / false 不使用
  # 事件中调用增减道具/武器/防具时，如果会导致超过负重上限，是否执行中断事件处理
  # 推荐不使用，因为新加的功能就有一个是当超过负重时限制角色移动，开启这个
  # 的话这个限制移动就无效了的说·3·

  Movable =  true       # true 使用 / false 不使用
  # 满负重时降低移动速度（不使用时禁止移动连事件都无法启动，只能丢弃/使用物品）

  Move_Speed = 2 # 满负重时的移动速度降低量

  # 负重超过上限时的提示内容
  Message = "负重超过承受范围，移动将变得\ec[10]【十分艰难！】\\c[0]" +
            "\n\ei[4]丢弃些没用的东西吧。"

  Lose_SW = true       # true 使用 / false 不使用
                       # 按X键（A键）是否可以丢弃道具
                       # 如果你另外使用了丢弃道具的脚本请关闭

  Help_SW = true       #true 使用 / false 不使用
  # 是否在帮助窗口内自动添加负重信息

  Equip_SW = true      #true 计算 / false 不计算
  # 装备在身上的装备是否算入负重
  #        "★★★★★★ 注意 ★★★★★★"
  # 如果你的角色初始装备有占负重并且开启上面的功能，那么你必须
  # 在游戏一开始时为当前负重赋值（自己算到底有多少负重·3·）
  # 当有新队员加入队伍并且也带有负重的装备那么你也需要为当前负重加上对应的重量，
  # 例如：$game_party.current_load += 10 就是加上10的当前负重
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class RPG::BaseItem
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 获取道具的重量
  #--------------------------------------------------------------------------
  def load
    return unless self.is_a?(RPG::Item) || self.is_a?(RPG::EquipItem)
    return $1.to_i if @note =~ /<(?:load|负重|負重)\s*(\d+)>/i
    Default_Load
  end
  #--------------------------------------------------------------------------
  # ● 新增负重帮助内容
  #--------------------------------------------------------------------------
  def description
    if Help_SW && load && load != 0
      @description + "\n\e}重量:#{load}\e{"
    else
      @description
    end
  end unless $VIPArcherScript[:help_ex]
end
#==============================================================================
# 　显示当前负重信息的窗口
#==============================================================================
class Window_Load < Window_Base
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(Graphics.width - window_width, 72, window_width, fitting_height(1))
    self.viewport = @viewport
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    Width
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    contents.font.size - 4
    change_color(system_color)
    draw_text(0, 0, window_width - 64, 24,Load_Name,0)
    change_color($game_party.load_max? ? power_down_color : normal_color)
    weight = "#{$game_party.current_load}/#{$game_party.total_load}"
    draw_text(0, 0, window_width - 24, 24, weight,2)
    @temp_load = $game_party.current_load
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    refresh if @temp_load != $game_party.current_load
  end
end
#-------------------------------------------------------------------------------
class Window_ItemCategory < Window_HorzCommand
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 获取窗口的宽度
  #--------------------------------------------------------------------------
  def window_width
    scene_item_is? ? Graphics.width - Width : Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 获取列数
  #--------------------------------------------------------------------------
  def col_max
    return scene_item_is? ? 3 : 4
  end
  #--------------------------------------------------------------------------
  # ● 判断是否为物品栏场景
  #--------------------------------------------------------------------------
  def scene_item_is?
    return SceneManager.scene_is?(Scene_Item)
  end
end
#==============================================================================
# ■ 物品界面显示负重栏
#==============================================================================
class Scene_Item < Scene_ItemBase
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 开始处理
  #--------------------------------------------------------------------------
  alias load_start start
  def start
    load_start
    @load_window = Window_Load.new(@viewport)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias load_update update
  def update
    #--------------------------------------------------------------------------
    # ★ 按X键（A键）丢弃道具 - 贵重物品无法丢弃 ★修改：VIPArcher
    #--------------------------------------------------------------------------
    if Input.trigger?(Input::X) && Lose_SW
      item = @item_window.item
      if item.is_a?(RPG::Item) && item.key_item? || item.nil?
        Sound.play_buzzer
      else
        Sound.play_cancel
        $game_party.lose_item(item, 1)
        @item_window.refresh
      end
    end
    load_update
  end
end
#-------------------------------------------------------------------------------
class Window_ShopNumber < Window_Selectable
  include VIPArcher::Load
  attr_accessor :buy_or_sell                    #买入的标志
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias vip_shopnumber_refresh refresh
  def refresh
    vip_shopnumber_refresh
    draw_current_weight(@item)
  end
  #--------------------------------------------------------------------------
  # ○ 买卖时重量变化的描绘
  #--------------------------------------------------------------------------
  def draw_current_weight(item)
    current = $game_party.current_load
    weight = current + item.load * @number * (@buy_or_sell ? 1 : -1)
    width = contents_width - 8
    cx = text_size(@currency_unit).width
    change_color(system_color)
    draw_text(4, y + 60, width, line_height, Load_Name)
    change_color(normal_color)
    wt = "#{weight} / #{$game_party.total_load}"
    change_color(power_down_color) if weight > $game_party.total_load
    draw_text(4, y + 60, width, line_height, wt, 2)
  end
end
#-------------------------------------------------------------------------------
class Window_ShopStatus < Window_Base
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias vip_shopstatus_refresh refresh
  def refresh
    vip_shopstatus_refresh
    draw_weight_occupy(4, 24)
  end
  #--------------------------------------------------------------------------
  # ● 绘制持负重信息
  #--------------------------------------------------------------------------
  def draw_weight_occupy(x, y)
    rect = Rect.new(x, y, contents.width - 4 - x, line_height)
    change_color(system_color)
    draw_text(rect, Load_Name, 3)
    change_color(normal_color)
    weight = "#{$game_party.current_load}/#{$game_party.total_load}"
    change_color(power_down_color) if $game_party.load_max?
    draw_text(rect, weight, 2)
    @temp_load = $game_party.current_load
  end
end
#==============================================================================
# ■ 获取队伍最大负重
#==============================================================================
class Game_Party < Game_Unit
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :current_load, :load_trade_item     #负重
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  alias load_initialize initialize
  def initialize
    load_initialize
    total_load
    @current_load = 0
    @total_load = 0
  end
  #--------------------------------------------------------------------------
  # ● 获取队伍最大负重
  #--------------------------------------------------------------------------
  def total_load
    return $game_variables[Load_Var] if Load_Var > 0
    all_members.inject(0) {|total,actor| total + actor.load }
  end
  #--------------------------------------------------------------------------
  # ● 判断负重是否已满
  #--------------------------------------------------------------------------
  def load_max?
    return false if @current_load == 0
    @current_load >= total_load
  end
  #--------------------------------------------------------------------------
  # ● 增加／减少物品时计算负重
  #--------------------------------------------------------------------------
  alias load_gain_item gain_item
  def gain_item(item, n, include_equip = false)
    return if item.nil?
    load_gain_item(item, n, include_equip)
    @current_load += item.load * n unless @load_trade_item
  end
end
#-------------------------------------------------------------------------------
class Game_Actor < Game_Battler
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 装备时不计算负重的增减 * 方法覆盖
  #     new_item : 取出的物品
  #     old_item : 放入的物品
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.load_trade_item = true if Equip_SW == true
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    $game_party.load_trade_item = false if Equip_SW == true
    return true
  end
  #--------------------------------------------------------------------------
  # ● 获取角色的负重上限
  #--------------------------------------------------------------------------
  def load
    eval(Load_Eval).to_i rescue msgbox "请检查负重能力公式是否正确"
  end
end
#==============================================================================
# ■ 增减物品时判断负重
#==============================================================================
class Game_Interpreter
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 增减道具
  #--------------------------------------------------------------------------
  alias load_command_126 command_126
  def command_126
    n = operate_value(@params[1], @params[2], @params[3])
    return command_115 if check_load($data_items[@params[0]], n) && Stop_SW
    load_command_126
  end
  #--------------------------------------------------------------------------
  # ● 增減武器
  #--------------------------------------------------------------------------
  alias load_command_127 command_127
  def command_127
    n = operate_value(@params[1], @params[2], @params[3])
    return command_115 if check_load($data_weapons[@params[0]], n) && Stop_SW
    load_command_127
  end
  #--------------------------------------------------------------------------
  # ● 增減防具
  #--------------------------------------------------------------------------
  alias load_command_128 command_128
  def command_128
    n = operate_value(@params[1], @params[2], @params[3])
    return command_115 if check_load($data_armors[@params[0]], n) && Stop_SW
    load_command_128
  end
  #--------------------------------------------------------------------------
  # ● 增减物品超重时提示
  #--------------------------------------------------------------------------
  def check_load(item, n)
    if (((item.load * n) + $game_party.current_load) > $game_party.total_load)
      $game_message.texts.push("#{Message}") if $game_message.visible != true
      $game_message.visible = true
    end
    ((item.load * n) + $game_party.current_load) > $game_party.total_load
  end
end
#==============================================================================
# ★ 满负重时限制行动 ★
#==============================================================================
class Game_Player < Game_Character
  include VIPArcher::Load
  #--------------------------------------------------------------------------
  # ● 判定是否可以移动
  #--------------------------------------------------------------------------
  alias load_movable? movable?
  def movable?
    return false if $game_party.load_max? && !Movable ; load_movable?
  end
  #--------------------------------------------------------------------------
  # ● 满负重时降低移动速度
  #--------------------------------------------------------------------------
  def real_move_speed
    return super - Move_Speed if $game_party.load_max? && Movable ; super
  end
end
#==============================================================================
# ★ 满负重时限制购买 ★
#==============================================================================
class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 查询商品是否可买
  #--------------------------------------------------------------------------
  alias load_enable? enable?
  def enable?(item)
    load_enable?(item) && !$game_party.load_max?
  end
end
#==============================================================================
# ★ 根据负重设定可购买的物品数量 ★
#==============================================================================
class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 指令“买入”
  #--------------------------------------------------------------------------
  alias vip_load_command_buy command_buy
  def command_buy
    vip_load_command_buy ; @number_window.buy_or_sell = true
  end
  #--------------------------------------------------------------------------
  # ● 指令“卖出”
  #--------------------------------------------------------------------------
  alias vip_load_command_sell command_sell
  def command_sell
    vip_load_command_sell ; @number_window.buy_or_sell = false
  end
  #--------------------------------------------------------------------------
  # ● 获取可以买入的最大值
  #--------------------------------------------------------------------------
  alias load_max_buy max_buy
  def max_buy
    vip = @item.load == 0 ? load_max_buy : ($game_party.total_load - 
    $game_party.current_load) / @item.load
    [load_max_buy,vip].min
  end
end