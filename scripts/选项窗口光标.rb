#==============================================================================
# ■ 选项窗口光标
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 httprm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 说明：
#     插入该脚本后游戏的的 Window_Selectable 及其之类窗口都会拥有一个光标。
#     光标文件放在 Graphics\System 文件夹下名为为 "WindowCursor" 
#     光标文件不存在时，会使用窗口皮肤的左向的那个小箭头作为光标。
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:window_cursor] = 20150513
#-------------------------------------------------------------------------------
module VIPArcher end
#==============================================================================
# ★ 设定部分 ★
#==============================================================================
module VIPArcher::WindowCursor
  FILENAME = "WindowCursor"  # 光标的文件名(放在 Graphics\System 文件夹下)
  BUFFER_X = 0               # 光标 X 坐标的修正量
  BUFFER_Y = 6               # 光标 Y 坐标的修正量
  EFFECT_TYPE  = 1           # 特效: nil => 无特效,1 => 横向,2 => 纵向
  EFFECT_SPEED = 6           # 特效滑动的速度(请不要设置为 0)
end
#==============================================================================
# ☆ 设定结束 ☆
#==============================================================================
class Sprite_WindowCursor < Sprite_Base
  include VIPArcher::WindowCursor
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(window)
    super(window.viewport)
    @window, @effect = window, [0,0,0]
    self.opacity, self.z = 0, @window.z + 200
    create_bitmap
  end
  #--------------------------------------------------------------------------
  # create_bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    begin
      self.bitmap = Cache.system(FILENAME)
    rescue
      self.bitmap = Bitmap.new(10, 16)
      self.bitmap.blt(0, 0,@window.windowskin, Rect.new(102, 24, 10, 16))
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新精灵
  #--------------------------------------------------------------------------
  def update
    super
    update_visibility
    update_position
    update_effect if Graphics.frame_count % EFFECT_SPEED == 0
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新特效
  #--------------------------------------------------------------------------    
  def update_effect
    return unless EFFECT_TYPE
    case @effect[0] += 1
    when 1..7  then @effect[EFFECT_TYPE] += 1
    when 8..14 then @effect[EFFECT_TYPE] -= 1
    else @effect[0] = 0 end
  end
  #--------------------------------------------------------------------------
  # ● 更新可见性
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = @window.visible
    self.opacity += @window.active ? 45 : -45
    self.opacity = 0 if @window.index < 0
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    rect = @window.cursor_rect
    self.x = @window.x + rect.x - @window.ox + BUFFER_X + @effect[1]
    self.y = @window.y + rect.y - @window.oy + 
      BUFFER_Y + rect.height / 2 + @effect[2]
  end
end
#==============================================================================
class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #-------------------------------------------------------------------------
  alias cursor_sprite_initialize initialize
  def initialize(x, y, width, height)
    cursor_sprite_initialize(x, y, width, height)
    create_cursor_sprite
  end
  #--------------------------------------------------------------------------
  # ● 创建光标 注：如果某类选项窗口不需要光标，可在其窗口类中重定义该方法
  #--------------------------------------------------------------------------
  def create_cursor_sprite
    @cursor_sprite = Sprite_WindowCursor.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  alias cursor_sprite_dispose dispose
  def dispose
    cursor_sprite_dispose
    @cursor_sprite.dispose if @cursor_sprite
  end
  #--------------------------------------------------------------------------
  # ● 更新画面
  #--------------------------------------------------------------------------
  alias cursor_sprite_update update
  def update
    cursor_sprite_update
    @cursor_sprite.update if @cursor_sprite
  end
end