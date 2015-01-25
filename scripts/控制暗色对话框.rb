#===============================================================================
#  暗色对话框控制 By：VIPArcher
#===============================================================================
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#  说明：对话中使用暗色对话框，并对变量1赋值可以控制对话所使用的背景图，
#    文件名规格是"Message_"+ 变量1的值
#    例如"Message_0.png" 或者"Message_VIPArcher.png"
#===============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:message_back] = 20141117
#==============================================================================
# ● 设定区
#==============================================================================
module VIPArcher end
module VIPArcher::MESSAGE
  AFFIX_VER = 1        #控制文件后缀名的变量ID
  BACK_NAME = "Message"#背景图片名字的前缀
end
#-------------------------------------------------------------------------------
class Window_Message < Window_Base
  include VIPArcher::MESSAGE
  #--------------------------------------------------------------------------
  # ● 生成背景位图
  #--------------------------------------------------------------------------
  alias vip_20141117_create_back_bitmap create_back_bitmap
  def create_back_bitmap
    back_bitmap_name = BACK_NAME + "_" + $game_variables[AFFIX_VER].to_s
    begin
    @back_bitmap = Cache.system(back_bitmap_name)# rescue Cache.system(BACK_NAME)
    rescue
    vip_20141117_create_back_bitmap
    end
    @game_variables = $game_variables[AFFIX_VER]
  end
  #--------------------------------------------------------------------------
  # ● 更新背景精灵
  #--------------------------------------------------------------------------
  alias vip_20141117_update_back_sprite update_back_sprite
  def update_back_sprite
    vip_20141117_update_back_sprite
    @back_sprite.y = Graphics.height - @back_bitmap.height
  end
  #--------------------------------------------------------------------------
  # ● 更新窗口背景
  #--------------------------------------------------------------------------
  alias vip_20141117_update_background update_background
  def update_background
    dispose_back_bitmap
    dispose_back_sprite
    create_back_bitmap
    create_back_sprite
    vip_20141117_update_background
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias vip_20141117_update update
  def update
    vip_20141117_update
    update_background if @game_variables != $game_variables[AFFIX_VER]
  end
end
