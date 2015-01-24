#===============================================================================
# ■ 八方向行走
# by ：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# ■ 使用说明：
#   在Characters里添加八方向行走图 在四方向素材文件名的基础上＋_8D
#   做为该素材的八方向行走图，(2×4的素材也得用2×4的八方向素材)
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:dir8_move] = 20141031
#--------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
#  ★ 设定部分 ★
#==============================================================================
module VIPArcher::DIR8
  OFF_SW = 0       #控制关闭八方向行走的开关(0"禁用"该功能)
  NAME_AFFIX = "_8D" #八方向行走图文件名后缀
end
#==============================================================================
#  ☆ 设定结束 ☆
#==============================================================================
class Game_Player
  #--------------------------------------------------------------------------
  # ● 由方向键移动
  #--------------------------------------------------------------------------
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    if [1, 3, 7, 9].include?(Input.dir8)
      case Input.dir8
      when 1; move_diagonal(4, 2)
      when 3; move_diagonal(6, 2)
      when 7; move_diagonal(4, 8)
      when 9; move_diagonal(6, 8)
      end
      return if @move_succeed
    end unless $game_switches[VIPArcher::DIR8::OFF_SW]
    move_straight(Input.dir4) if Input.dir4 > 0
  end
end
#--------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 设置角色的位图
  #--------------------------------------------------------------------------
  alias dir8_set_character set_character_bitmap
  def set_character_bitmap
    dir8_set_character
    set_dir8_bitmap
  end
  #--------------------------------------------------------------------------
  # ● 设置八方向的位图
  #--------------------------------------------------------------------------
  def set_dir8_bitmap
    dir8_name = @character_name + VIPArcher::DIR8::NAME_AFFIX
    @character_dir4 = self.bitmap.clone
    @character_dir8 = Cache.character(dir8_name) rescue @character_dir4
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @tile_id != 0
    index = @character.character_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw
    if @character.direction % 2 == 1
      self.bitmap = @character_dir8
      sy = (index / 4 * 4 + (@character.direction + 1) / 3) * @ch
    else
      self.bitmap = @character_dir4
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    end
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  alias dir8_dispose dispose
  def dispose
    dir8_dispose
    @character_dir4.dispose if @character_dir4
    @character_dir8.dispose if @character_dir8
  end
end