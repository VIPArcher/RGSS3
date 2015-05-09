#==============================================================================
# ■ 地图卷动扩展
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 httprm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 说明：
#     事件脚本里调用 start_scroll(direction, distance, speed)来进行画面卷动
#    direction:  7  8  9     distance：卷动距离 
#                 ↖↑↗            speed:卷动速度 1 - 6
#                4← →6           1:  1/8倍速度； 2:  1/4倍速度
#                 ↙↓↘            3:  1/2倍速度； 4:  正常速度
#                1  2  3           5:    2倍速度； 6:  4倍速度
#    如果斜向移动到边界时则会变成水平方向卷动
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:map_scroll] = 20150503
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 执行地图卷动 start_scroll(direction, distance, speed)
  #   direction 卷动方向(1-9) 
  #   distance  卷动距离(格数)
  #   speed     卷动速度(1-6)
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    Fiber.yield while $game_map.scrolling?
    $game_map.start_scroll(direction, distance, speed)
  end
end
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ● 执行卷动
  #--------------------------------------------------------------------------
  def do_scroll(direction, distance)
    case direction
    when 1;  scroll_down (distance);scroll_left (distance)
    when 2;  scroll_down (distance)
    when 3;  scroll_down (distance);scroll_right(distance)
    when 4;  scroll_left (distance)
    when 5;
    when 6;  scroll_right(distance)
    when 7;  scroll_up   (distance);scroll_left (distance)
    when 8;  scroll_up   (distance)
    when 9;  scroll_up   (distance);scroll_right(distance)
    end
  end
end