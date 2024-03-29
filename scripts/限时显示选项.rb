#==============================================================================
# ■ 限时显示选项
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
# 说明：
#   在开始选择前开启计时器，如果计时器归0时自动调用“取消”的方法。要保证取消有效。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:time_choiceList] = 20141027
#--------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::Time_Choice
  ID = 1  # 这个开关开启时，显示选项将在计时器归零时自动调用"取消"的方法
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Window_ChoiceList < Window_Command
  include VIPArcher::Time_Choice
  #--------------------------------------------------------------------------
  # ● 调用“取消”的处理方法
  #--------------------------------------------------------------------------
  alias timer_call_cancel_handler call_cancel_handler
  def call_cancel_handler
    timer_call_cancel_handler
    return unless $game_switches[ID]
    deactivate; $game_timer.stop
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias timer_update update
  def update
    timer_update
    return unless $game_switches[ID]
    call_cancel_handler if cancel_enabled? &&
    $game_timer.sec.zero? && $game_timer.working?
  end
end