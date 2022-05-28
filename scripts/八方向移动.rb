#===============================================================================
# ■ 八向移动待机行走图动画扩展
# by ：VIPArcher [email: VIPArcher@sina.com]
#  -- Project1 论坛：https://rpg.blue/ 使用或转载请保留以上信息。
#==============================================================================
# ■ 使用说明：
#   行走图素材文件名最前面添加 '@' 符号视为该角色/事件使用八方向行走图
#   需为其配置对应的其他形态的行走图文件，文件名后缀规则请看设定部分
#     例如  $@Actor1.png / @Actor1.png
#   文件名中带上 [f帧数#默认帧] 来控制行走图动画的帧数和停下时使用的帧
#     例如  $@Actor[f8#4].png / @Actor1[f8#4].png
#   事件也要使用待机动画需要在事件页（当前页）中备注上 <idle_anime>
#   事件的移动速度超过 5 则使用奔跑行走图
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:dir8_anime] = 20181212
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher end
module VIPArcher::DIR8_ANIME
  # 配置开始
  DIR8_OFF_SW   = 0  # 控制关闭八方向行走的开关
  IDLE_ANIME_SW = 0  # 控制关闭待机动画的开关
  DASH_ANIME_SW = 0  # 控制关闭奔跑动画的开关
  IDLE_TIME   = 120  # 静止后进入待机动画的时间(帧)
  RIDLE_TIME  = 120  # 待机等待时间浮动值（上下浮动该值一半）默认即 60 - 180 帧
  ANIME_TIME  = 1    # 待机动画循环次数
  GAP_TIME    = 120  # 两次待机动画之间的时间间隔
  IDLE_NOTE   = '<idle_anime>' # 事件使用待机动画的备注
  DASH4_AFFIX = '_DASH'    # 奔跑普通行走图后缀
  IDLE4_AFFIX = '_IDLE'    # 待机普通行走图后缀
  DIRE8_AFFIX = '_8D'      # 普通斜向行走图后缀
  DASH8_AFFIX = '_DASH_8D' # 奔跑斜向行走图后缀（此条仅参考命名，没有实际作用）
  IDLE8_AFFIX = '_IDLE_8D' # 待机斜向行走图后缀（此条仅参考命名，没有实际作用）
  # 配置结束
  #--------------------------------------------------------------------------
  # ● 判断是否多帧
  #--------------------------------------------------------------------------
  def is_multi_frames?
    character_name =~ /\[f\d+#?\d*\]/i
  end
  #--------------------------------------------------------------------------
  # ● 获取帧数
  #--------------------------------------------------------------------------
  def get_frame(character_name)
    character_name =~ /\[f(\d+)#?\d*\]/i ? $1.to_i : 4
  end
  #--------------------------------------------------------------------------
  # ● 获取原图案（静止时矫正帧）
  #--------------------------------------------------------------------------
  def get_halt_name(character_name)
    character_name =~ /\[f\d+#(\d+)\]/i ? $1.to_i : 1
  end
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player
  include VIPArcher::DIR8_ANIME
  #--------------------------------------------------------------------------
  # ● 由方向键移动
  #--------------------------------------------------------------------------
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    if [1, 3, 7, 9].include?(Input.dir8)
      case Input.dir8
      when 1 then move_diagonal(4, 2)
      when 3 then move_diagonal(6, 2)
      when 7 then move_diagonal(4, 8)
      when 9 then move_diagonal(6, 8)
      end; return if @move_succeed
    end unless $game_switches[DIR8_OFF_SW]
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    dash? && @stop_count.zero?
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias set_frame_refresh refresh
  def refresh
    set_frame_refresh
    @frame = get_frame(@character_name)
    @original_pattern = get_halt_name(@character_name)
  end
end
class Game_Follower
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    $game_player.is_dash?
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias set_frame_refresh refresh
  def refresh
    set_frame_refresh
    @frame = get_frame(@character_name)
    @original_pattern = get_halt_name(@character_name)
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  # * 使队员待机动画不同步，没用alias，如有冲突，请把该脚本放置被冲突脚本上面
  #--------------------------------------------------------------------------
  def update
    @move_speed     = $game_player.real_move_speed
    @transparent    = $game_player.transparent
    @walk_anime     = $game_player.walk_anime
    @step_anime     = @step_anime  #踏步属性不继承队伍
    @direction_fix  = $game_player.direction_fix
    @opacity        = $game_player.opacity
    @blend_type     = $game_player.blend_type
    super
  end
end
class Game_Event
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    !@locked && @move_speed >= 5 && @stop_count.zero?
  end
  #--------------------------------------------------------------------------
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def idle_anime?
    @idle_note && @idle_anime
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias set_frame_refresh refresh
  def refresh
    set_frame_refresh
    @frame = get_frame(@character_name)
    @original_pattern = get_halt_name(@character_name)
    @list.each do |command|
      if [108, 408].include?(command.code)
        return @idle_note = true if command.parameters.any? do |line|
          line =~ /#{IDLE_NOTE}/i
        end
      end
    end if @list
  end
end
#==============================================================================
# ■ Game_CharacterBase
#==============================================================================
class Game_CharacterBase
  include VIPArcher::DIR8_ANIME
  attr_reader :frame
  attr_reader :static_anime
  attr_accessor :idle_anime
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias dir8_update update
  def update
    dir8_update
    return if $game_switches[IDLE_ANIME_SW]
    return unless idle_anime?
    @step_anime = update_static_anime
  end
  #--------------------------------------------------------------------------
  # ● 更新待机动画
  #--------------------------------------------------------------------------
  def update_static_anime
    case @stop_count
    when static_anime_idle_time...(static_anime_idle_time + idle_anime_time)
      @static_anime = true
    when static_anime_idle_time + idle_anime_time
      @stop_count = static_anime_idle_time - GAP_TIME
      @pattern = @original_pattern
      @static_anime = false
    else @static_anime = false end
  end
  #--------------------------------------------------------------------------
  # ● 进入待机前等待时间获取
  #--------------------------------------------------------------------------
  def static_anime_idle_time
    @anime_idle_time ||= (IDLE_TIME - RIDLE_TIME / 2 + rand(RIDLE_TIME)).to_i
  end
  #--------------------------------------------------------------------------
  # ● 待机总帧数获取
  #--------------------------------------------------------------------------
  def idle_anime_time
    ANIME_TIME * @frame * animation_wait
  end
  #--------------------------------------------------------------------------
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def idle_anime?; @idle_anime end
  #--------------------------------------------------------------------------
  # ● 是否奔跑
  #--------------------------------------------------------------------------
  def is_dash?; false end
  #--------------------------------------------------------------------------
  # ● 初始化私有成员变量
  #--------------------------------------------------------------------------
  alias set_frame_init_private_members init_private_members
  def init_private_members
    set_frame_init_private_members
    @frame = 4
  end
  #--------------------------------------------------------------------------
  # ● 更新步行／踏步动画
  #--------------------------------------------------------------------------
  def update_animation
    update_anime_count
    if @anime_count > animation_wait
      update_anime_pattern
      @anime_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 移动时两帧之间等待时间
  #--------------------------------------------------------------------------
  def animation_wait
    [(9 - real_move_speed) * 3, 2].max
  end
  #--------------------------------------------------------------------------
  # ● 矫正姿势
  #--------------------------------------------------------------------------
  def straighten
    @pattern = @original_pattern if @walk_anime || @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新动画图案
  #--------------------------------------------------------------------------
  def update_anime_pattern
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % @frame
    end
  end
  #--------------------------------------------------------------------------
  # ● 更改图像
  #--------------------------------------------------------------------------
  alias set_frame_set_graphic set_graphic
  def set_graphic(character_name, character_index)
    set_frame_set_graphic(character_name, character_index)
    @frame = get_frame(character_name)
    @original_pattern = get_halt_name(character_name)
  end
  #--------------------------------------------------------------------------
  # ● 斜向移动
  #--------------------------------------------------------------------------
  alias dir8_move_diagonal move_diagonal
  def move_diagonal(horz, vert)
    return @move_succeed = false if !passable?(@x, @y, horz) && !passable?(@x, @y, vert)
    return move_straight(horz) if passable?(@x, @y, horz) && !passable?(@x, @y, vert)
    return move_straight(vert) if passable?(@x, @y, vert) && !passable?(@x, @y, horz)
    dir8_move_diagonal(horz, vert)
    case [horz,vert]
    when [4,2] then set_direction(1)
    when [4,8] then set_direction(7)
    when [6,2] then set_direction(3)
    when [6,8] then set_direction(9)
    end
  end
end
#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  include VIPArcher::DIR8_ANIME
  #--------------------------------------------------------------------------
  # ● 是否是八方向素材
  #--------------------------------------------------------------------------
  def is_dir8?
    return false if @character_name =~ /#{DIRE8_AFFIX}/
    return @character_name =~ /^(\@|\!\@|\$@|\!\$\@).+/
  end
  #--------------------------------------------------------------------------
  # ● 设置角色的位图
  #--------------------------------------------------------------------------
  alias dir8_move_set_character_bitmap set_character_bitmap
  def set_character_bitmap
    dir8_move_set_character_bitmap
    return unless is_dir8?
    @character_dir8 = {}
    set_character_dir8("", "")
    set_character_dir8(DASH4_AFFIX, DASH4_AFFIX)
    set_character_dir8(IDLE4_AFFIX, IDLE4_AFFIX)
    set_character_dir8(DIRE8_AFFIX, DIRE8_AFFIX)
    set_character_dir8(DASH8_AFFIX, DASH8_AFFIX, DIRE8_AFFIX)
    set_character_dir8(IDLE8_AFFIX, IDLE8_AFFIX, DIRE8_AFFIX)
    frame = @character.is_multi_frames? ? @character.frame : 3
    sign = @character_name[/^[\@\!\$]../]
    @cw = bitmap.width / frame
    @cw /= 4 unless sign && sign.include?('$')
    self.ox = @cw / 2
  end
  #--------------------------------------------------------------------------
  # ● 设置角色的各状态图
  #--------------------------------------------------------------------------
  def set_character_dir8(string, affix, default = "")
    begin
      @character_dir8[string.to_sym] = Cache.character(@character_name + affix)
      @character.idle_anime = true if string.include?(IDLE4_AFFIX)
    rescue
      @character_dir8[string.to_sym] = @character_dir8[default.to_sym]
      @character.idle_anime = false if string.include?(IDLE4_AFFIX)
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @tile_id != 0
    index = @character.character_index
    frame = @character.is_multi_frames? ? @character.frame : 3
    first = @character.is_multi_frames? ? 0 : 1
    pattern = @character.pattern < frame ? @character.pattern : first
    if (anime_symbol = "#{
      @character.is_dash? && !$game_switches[DASH_ANIME_SW] ?
      DASH4_AFFIX : @character.static_anime ? IDLE4_AFFIX : ''
    }#{@character.direction.odd? ? DIRE8_AFFIX : ''}".to_sym) != @anime_symbol
      @anime_symbol = anime_symbol
      self.bitmap = @character_dir8[anime_symbol]
    end if is_dir8?
    sx = (index % 4 * frame + pattern) * @cw
    if (dir = @character.direction).odd?
      dir = [3, 7].include?(dir) && !is_dir8? ? 10 - dir : dir
      sy = (index / 4 * 4 + (dir + 1) / 3) * @ch
    else
      sy = (index / 4 * 4 + (dir - 2) / 2) * @ch
    end
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  alias dir8_dispose dispose
  def dispose
    dir8_dispose
    @character_dir8.each_value do |v|
      v.dispose unless v.disposed?
    end if @character_dir8
  end
end