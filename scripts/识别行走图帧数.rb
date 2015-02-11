#==============================================================================
# ■ 自动识别行走图帧数
# By ：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
# 说明：
#   使用这个脚本可以自动识别行走图的帧数，并且设置角色使用该行走图时的默认动作，使用
#   方法是在行走图文件名里加上@帧数#默认动作的帧。事件的默认帧可以在事件里直接设置
#   例如XP的素材就命名为:  "喵喵喵_@4#0.png" 或者  "$妙妙妙_@4#0.png"
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:characters_frame] = 20150122
#-------------------------------------------------------------------------------
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● 矫正姿势
  #--------------------------------------------------------------------------
  def straighten
    return super unless @fix
    @pattern = @fix if @walk_anime || @step_anime
    @anime_count = 0
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  alias characters_frame_refresh refresh
  def refresh
    characters_frame_refresh
    @original_pattern = @fix = $1.to_i if @character_name =~ /#(\d+)/
    @frame = $1.to_i if @character_name =~ /@(\d+)/
  end
  #--------------------------------------------------------------------------
  # ● 更新动画图案
  #--------------------------------------------------------------------------
  def update_anime_pattern
    return super unless @frame
    if !@step_anime && @stop_count > 0
      @pattern = @original_pattern
    else
      @pattern = (@pattern + 1) % @frame
    end
  end
end
#-------------------------------------------------------------------------------
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 设置角色的位图
  #--------------------------------------------------------------------------
  alias characters_frame_set_character_bitmap set_character_bitmap
  def set_character_bitmap
    if @character_name =~ /@(\d+)/
      @frame = $1.to_i
      self.bitmap = Cache.character(@character_name)
      sign = @character_name[/^[\!\$]./]
      if sign && sign.include?('$')
        @cw = bitmap.width / @frame
        @ch = bitmap.height / 4
      else
        @cw = bitmap.width / @frame * 4
        @ch = bitmap.height / 8
      end
      self.ox = @cw / 2
      self.oy = @ch
    else
      characters_frame_set_character_bitmap
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  alias characters_frame_update_src_rect update_src_rect
  def update_src_rect
    return characters_frame_update_src_rect unless @frame
    if @tile_id == 0
      index = @character.character_index
      pattern = @character.pattern < @frame ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
end