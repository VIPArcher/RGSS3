#===============================================================================
# ■ 八方向移动行走图动画扩展
# by ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# ■ 使用说明：
#   行走图素材文件名最前面添加 '@'符号视为该角色/事件使用八方向行走图
#   素材规格为2 * 4角色元的素材，其中第一角色元为正常状态行走图，下面
#   也就是第五角色元为对应的斜向行走图，第二角色元为奔跑时行走图，下面
#   也就是第六角色元为对应奔跑时斜向行走图，第三角色元为站立一段时间后
#   待机播放的踏步行走图，下面也就是第七角色元为对应斜向踏步行走图。
#          例如  @Actor1.png :
#         ┌───┬───┬───┬───┐
#         │　步　│　奔　│　待　│　　　│
#         │　行　│　跑　│　机　│　　　│
#         │　行　│　行　│　行　│　　　│
#         │　走　│　走　│　走　│　　　│
#         │　图　│　图　│　图　│　　　│
#         ├───┼───┼───┼───┤
#         │　斜　│　斜　│　斜　│　　　│
#         │　向　│　向　│　向　│　　　│
#         │　步　│　奔　│　待　│　　　│
#         │　行　│　跑　│　机　│　　　│
#         └───┴───┴───┴───┘
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:dir8_move] = 20161106
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher end
module VIPArcher::Dir_8
  OFF_SW = 0        # 控制关闭八方向行走的开关
  STEP_ANIME_SW = 1 # 控制待机动画启用的开关
  WAIT_TIME  = 150  # 静止后进入待机动画的时间(帧)
  ANIME_TIME = 25   # 待机动画播放的时长(帧)
  GAP_TIME   = 90   # 两次待机动画之间的时间间隔
end
#==============================================================================
# ■ Game_Player
#==============================================================================
class Game_Player
  include VIPArcher::Dir_8
  attr_reader   :static_anime
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
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias dir8_update update
  def update
    dir8_update
    return if $game_switches[STEP_ANIME_SW]
    @step_anime = case @stop_count
    when WAIT_TIME...WAIT_TIME + ANIME_TIME then @static_anime = true
    when WAIT_TIME + ANIME_TIME then @stop_count = WAIT_TIME - GAP_TIME
    @static_anime = false else @static_anime = false end
  end
end
#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event
  #--------------------------------------------------------------------------
  # ● 是否奔跑中
  #--------------------------------------------------------------------------
  def is_dash?
    return !@locked && @move_speed >= 5 && @stop_count.zero? 
  end
end
#==============================================================================
# ■ Game_CharacterBase
#==============================================================================
class Game_CharacterBase
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
    when [4,8] then set_direction(3)
    when [6,2] then set_direction(7)
    when [6,8] then set_direction(9)
    end
  end
end
#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 是否是八方向素材
  #--------------------------------------------------------------------------
  def is_dir8?
    return @character_name =~ /^\@.+/
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @tile_id != 0
    index = @character.character_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    index = if @character.is_dash? then 1
    elsif @character.instance_of?(Game_Player) && $game_player.static_anime
    2 else 0 end if is_dir8?
    sx = (index % 4 * 3 + pattern) * @cw
    unless @character.direction.even?
      index += 4 if is_dir8?
      sy = (index / 4 * 4 + (@character.direction + 1) / 3) * @ch
    else
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    end
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end
