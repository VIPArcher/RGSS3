#==============================================================================
# ■ 面向事件显示心情
# by ：VIPArcher
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#------------------------------------------------------------------------------
# ■ 使用说明：
#  面向注释有 <balloon id> 的事件时，玩家头顶显示第id号心情。心情素材直接使用的是
#  默认的心情素材。（其实默认的心情素材是可以直接扩展的，)
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:remind_balloon] = 20150125
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::Remind
  SPEED = 4             # 心情显示的速度
  WAIT_TIME = 90        # 最终帧的等待时间
  FILENAME = "Balloon"  # 心情素材的文件名
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Sprite_Remind < Sprite_Character
  include VIPArcher::Remind
  #--------------------------------------------------------------------------
  # ● 获取面前事件
  #--------------------------------------------------------------------------
  def event
    fx = $game_map.round_x_with_direction(character.x, character.direction)
    fy = $game_map.round_y_with_direction(character.y, character.direction)
    return $game_map.events_xy(fx, fy)[0]
  end
  #--------------------------------------------------------------------------
  # ● 获取事件的注释心情编号(如果有)
  #--------------------------------------------------------------------------
  def get_balloon_id(event)
    return 0 if event.nil? || event.list.nil?
    event.list.each do |command|
      if command.code == 108 || command.code == 408
        command.parameters.each do |line|
          return $1.to_i if line =~ /<balloon\s*(\d+)>/i
        end
      end
    end ; 0
  end
  #--------------------------------------------------------------------------
  # ● 开始显示心情图标
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * balloon_speed + balloon_wait
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system(FILENAME)
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    update_balloon
  end
  #--------------------------------------------------------------------------
  # ● 心情图标的显示速度
  #--------------------------------------------------------------------------
  def balloon_speed ; SPEED end
  #--------------------------------------------------------------------------
  # ● 心情最终帧的等待时间
  #--------------------------------------------------------------------------
  def balloon_wait ; WAIT_TIME end
  #--------------------------------------------------------------------------
  # ● 结束心情图标的显示
  #--------------------------------------------------------------------------
  def end_balloon
    dispose_balloon
    @balloon_id = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    super
    self.y = @character.screen_y - 32
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  def update
    super
    if @balloon_id != get_balloon_id(event)
      @balloon_id = get_balloon_id(event)
      start_balloon if @balloon_id > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 清空父类方法内容
  #--------------------------------------------------------------------------
  def update_bitmap ; end ; def setup_new_effect ; end
  def end_animation ; end ; def update_src_rect  ; end
  def update_other  ; end ; def update_other     ; end
end
#-------------------------------------------------------------------------------
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 生成提示心情精灵
  #--------------------------------------------------------------------------
  alias balloon_remind_create_characters create_characters
  def create_characters
    balloon_remind_create_characters
    @remind_sprite = Sprite_Remind.new(@viewport2,$game_player)
  end
  #--------------------------------------------------------------------------
  # ● 刷新提示心情精灵
  #--------------------------------------------------------------------------
  alias balloon_remind_update update
  def update
    balloon_remind_update ; @remind_sprite.update
  end
  #--------------------------------------------------------------------------
  # ● 释放提示心情精灵
  #--------------------------------------------------------------------------
  alias balloon_remind_dispose dispose
  def dispose
    balloon_remind_dispose ; @remind_sprite.dispose
  end
end