#==============================================================================
# ■ 跳过标题
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:skip_title] = 20140701
#--------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::SkipTitle
  Allowed = false      #是否允许返回标题
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class << SceneManager
  def first_scene_class
    DataManager.setup_new_game
    $game_map.autoplay
    Scene_Map
  end
end unless $BTEST
#-------------------------------------------------------------------------------
class Scene_End < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 返回标题改成开始新游戏
  #--------------------------------------------------------------------------
  def command_to_title
    DataManager.setup_new_game
    close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end unless VIPArcher::SkipTitle::Allowed
end
#-------------------------------------------------------------------------------
class Scene_Gameover < Scene_Base
  #--------------------------------------------------------------------------
  # ● 结束游戏画面切换到标题画面
  #--------------------------------------------------------------------------
  def goto_title
    DataManager.setup_new_game
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end unless VIPArcher::SkipTitle::Allowed
end
#-------------------------------------------------------------------------------
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 返回标题画面
  #--------------------------------------------------------------------------
  def command_354
    DataManager.setup_new_game
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
    Fiber.yield
  end unless VIPArcher::SkipTitle::Allowed
end