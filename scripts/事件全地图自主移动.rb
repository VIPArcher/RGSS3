#==============================================================================
# ■ 事件全地图自主移动
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 httprm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 说明：
#     事件内容里注释有 <move> 的事件可以全地图自主移动，不会因为不在视
#     野范(画面)围内而停下，(默认事件是不在视野范围内就停止自主移动的。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:map_self_movem] = 20150118
#-------------------------------------------------------------------------------
class Game_Event
  #--------------------------------------------------------------------------
  # ● 自动移动的更新
  #--------------------------------------------------------------------------
  alias self_movement update_self_movement
  def update_self_movement
    return self_movement if note_move?
    if @stop_count > stop_count_threshold
      case @move_type
      when 1 then move_type_random
      when 2 then move_type_toward_player
      when 3 then move_type_custom
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 判定是否注释有全地图自主移动
  #--------------------------------------------------------------------------
  def note_move?
    return true if @list.nil?
    @list.each do |command|
      if command.code == 108 or command.code == 408
        command.parameters.each do |line|
          return false if line.include?("<move>")
        end
      end
    end
  end
end