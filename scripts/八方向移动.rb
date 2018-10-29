#===============================================================================
# ■ 八方向移动行走图动画扩展
# by ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
# ■ 使用说明：
#   行走图素材文件名最前面添加 '$@' / '!$@' 符号视为该角色/事件使用八方向行走图
#   需为其配置对应的其他形态的行走图文件，文件名后缀规则请看设定部分
#     例如  $@Actor1.png / !$@Actor1.png
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:dir8_move] = 20161106
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher end
module VIPArcher::Dir8_ANIME
  OFF_SW = 0         # 控制关闭八方向行走的开关
  STEP_ANIME_SW = 1  # 控制待机动画启用的开关
  WAIT_TIME   = 150  # 静止后进入待机动画的时间(帧)
  ANIME_TIME  = 50   # 待机动画播放的时长(帧)
  GAP_TIME    = 90   # 两次待机动画之间的时间间隔
  WAIT_NOTE   = '<wait_anime>' # 事件使用待机动画的备注
  DASH4_AFFIX = '_DASH'   # 奔跑普通行走图后缀
  WAIT4_AFFIX = '_WAIT'   # 待机普通行走图后缀
  DIRE8_AFFIX = '_8D'     # 普通斜向行走图后缀
  DASH8_AFFIX = '_DASH8D' # 奔跑斜向行走图后缀
  WAIT8_AFFIX = '_WAIT8D' # 待机斜向行走图后缀
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player
  include VIPArcher::Dir8_ANIME
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
    end unless $game_switches[OFF_SW]
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    return dash? && @stop_count.zero?
  end
  #--------------------------------------------------------------------------
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def wait_anime?
    return true
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
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def wait_anime?
    return true
  end
end
class Game_Event
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    return !@locked && @move_speed >= 5 && @stop_count.zero? 
  end
  #--------------------------------------------------------------------------
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def wait_anime?
    wait = false
    @list.each do |command|
      if [108, 408].include?(command.code)
        wait = command.parameters.any? {|line| line =~ /#{WAIT_NOTE}/i }
      end
    end if @list
    return wait
  end
end
#==============================================================================
# ■ Game_CharacterBase
#==============================================================================
class Game_CharacterBase
  include VIPArcher::Dir8_ANIME
  attr_reader   :static_anime
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias dir8_update update
  def update
    dir8_update
    return if $game_switches[STEP_ANIME_SW]
    return unless wait_anime?
    @step_anime = case @stop_count
    when WAIT_TIME...WAIT_TIME + ANIME_TIME
      @static_anime = true
    when WAIT_TIME + ANIME_TIME
      @stop_count = WAIT_TIME - GAP_TIME
      @pattern = 1
      @static_anime = false
    else @static_anime = false end
  end
  #--------------------------------------------------------------------------
  # ● 是否待机动画
  #--------------------------------------------------------------------------
  def wait_anime?
    return false
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
    when [6,2] then set_direction(3)
    when [4,8] then set_direction(7)
    when [6,8] then set_direction(9)
    end
  end
end
#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  include VIPArcher::Dir8_ANIME
  #--------------------------------------------------------------------------
  # ● 是否是八方向素材
  #--------------------------------------------------------------------------
  def is_dir8?
    return @character_name =~ /^(\$@|\!\$@).+/
  end
  alias dir8_move_set_character_bitmap set_character_bitmap
  #--------------------------------------------------------------------------
  # ● 设置角色的位图
  #--------------------------------------------------------------------------
  def set_character_bitmap
    dir8_move_set_character_bitmap
    return unless is_dir8?
    sign = @character_name[/^[\!\$\@]./]
    index = @character.character_index
    @sw, @sh = self.bitmap.width, self.bitmap.height
    default_bit = Bitmap.new(@sw, @sh)
    dest_rect = Rect.new(0, 0, @sw, @sh / 4)
    src_rect = Rect.new(0, 0, @sw, @sh / 4)
    default_bit.stretch_blt(dest_rect, bitmap, src_rect)
    dest_rect.y += @sh / 4;src_rect.y += @sh / 2
    default_bit.stretch_blt(dest_rect, bitmap, src_rect)
    dest_rect.y += @sh / 4;src_rect.y -= @sh / 4
    default_bit.stretch_blt(dest_rect, bitmap, src_rect)
    dest_rect.y += @sh / 4;src_rect.y += @sh / 2
    default_bit.stretch_blt(dest_rect, bitmap, src_rect)
    dashd4 = Cache.character(@character_name + DASH4_AFFIX) rescue self.bitmap
    waitd4 = Cache.character(@character_name + WAIT4_AFFIX) rescue self.bitmap
    dired8 = Cache.character(@character_name + DIRE8_AFFIX) rescue default_bit
    dashd8 = Cache.character(@character_name + DASH8_AFFIX) rescue default_bit
    waitd8 = Cache.character(@character_name + WAIT8_AFFIX) rescue default_bit
    @character_dir8 = Bitmap.new(@sw * 4, @sh * 2)
    dest_rect = Rect.new(0, 0, @sw, @sh)
    @character_dir8.stretch_blt(dest_rect, bitmap, bitmap.rect)
    dest_rect.x += @sw
    @character_dir8.stretch_blt(dest_rect, dashd4, dashd4.rect)
    dest_rect.x += @sw
    @character_dir8.stretch_blt(dest_rect, waitd4, waitd4.rect)
    dest_rect.y += @sh; dest_rect.x = 0
    @character_dir8.stretch_blt(dest_rect, dired8, dired8.rect)
    dest_rect.x += @sw
    @character_dir8.stretch_blt(dest_rect, dashd8, dashd8.rect)
    dest_rect.x += @sw
    @character_dir8.stretch_blt(dest_rect, waitd8, waitd8.rect)
    @cw = @character_dir8.width / 12
    @ch = @character_dir8.height / 8
    self.bitmap = @character_dir8
    default_bit.dispose
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @tile_id != 0
    index = @character.character_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    index = if @character.is_dash? then 1
    elsif @character.static_anime
    2 else 0 end if is_dir8?
    sx = (index % 4 * 3 + pattern) * @cw
    if (dir = @character.direction).odd?
      index += 4 if is_dir8?
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
    @character_dir8.dispose if @character_dir8
  end
end
