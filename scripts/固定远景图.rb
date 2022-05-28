#==============================================================================
# ■ 固定远景图
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 https://rpg.blue 使用或转载请保留以上信息。
#==============================================================================
# 使用说明：
#   如果文件名以 ! 开头，则该远景会跟随地图卷动,也就是相当于固定在地图上了。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:fix_parallax] = 20150119
#------------------------------------------------------------------------------
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 更新远景图
  #--------------------------------------------------------------------------
  alias fix_update_parallax update_parallax
  def update_parallax
    fix_update_parallax
    return unless @parallax_name[0,1] == '!'
    @parallax.ox, @parallax.oy = @tilemap.ox, @tilemap.oy
  end
end
