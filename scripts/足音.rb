﻿#==============================================================================
# +++ 足音 v1.1 +++
# By：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# v1.1 删掉一些不必要的语句
# v1.0 完成基础脚本
#==============================================================================
# 
# 设定玩家在不同地形标志移动时不同的脚步声
# 
# 如果不想用地形标志来判断，想用区域ID的话就把脚本倒数第9行？
# $game_player.terrain_tag 改成 $game_player.region_id
# 
# 脚步声的素材名称命名是有一定规则的。例如Step0_0
# "Step"+地形标志ID+"_"+随机编号（0-3）
# 脚步声素材每组4枚。例如地形标志为2的脚步声
# 就命名为[Step2_0.ogg;Step2_1.ogg;Step2_2.ogg;Step2_3.ogg]
# 也可以设置一些区域是没有脚步声的。
# 效果的开关可以通过控制设置的开关进行控制
#
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:footsound] = 20140909
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::FOOTSOUND
  SW = 1           #关闭脚步声开关编号 打开此开关不播放脚步声
  NOSOUND = [0,1]   #没有脚步声的地形标志
  SOUNDURL = "Audio/SE/Footsound/" #脚本声素材路径
  VOL = 50     #音量
  PITCH = 100  #音调
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Game_Party < Game_Unit
  include VIPArcher::FOOTSOUND
  #--------------------------------------------------------------------------
  # ● 角色移动一步时的处理
  #--------------------------------------------------------------------------
  alias vip_20140909_on_player_walk on_player_walk
  def on_player_walk
    vip_20140909_on_player_walk
    foot_sound_play
  end
  #--------------------------------------------------------------------------
  # ● 播放脚步声  #要用区域ID就改成 tag = $game_player.region_id
  #--------------------------------------------------------------------------
  def foot_sound_play
    tag = $game_player.terrain_tag
    return if $game_switches[SW]
    return if NOSOUND.include?(tag)
    Audio.se_play("#{SOUNDURL}Step#{tag}_#{rand(4)}",VOL,PITCH) if @step_off
    @step_off ^= true #这里只是为了每2步才播放一次脚本声
  end
end