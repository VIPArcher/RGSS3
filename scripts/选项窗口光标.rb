#==============================================================================
# ■ 选项窗口光标
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 http://rm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# 说明：
#     插入该脚本后游戏的的 Window_Selectable 及其子类窗口都会拥有一个光标。
#     光标文件放在 Graphics\System 文件夹下名为为 "WindowCursor" 
#     光标文件不存在时，会使用窗口皮肤的右向的那个小箭头作为光标。
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
  EFFECT_SPEED = 8           # 刷新特性的速度(请勿设置为 0)
  CURSOR_FRAME = 1           # 光标的帧数（使用素材做光标时的素材帧数）
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
    @window, @effect, self.opacity = window, [0,0,0], 0
    create_bitmap
  end
  #--------------------------------------------------------------------------
  # create_bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    begin
      self.bitmap = Cache.system(FILENAME)
      @w, @h, @frame = self.bitmap.width / CURSOR_FRAME, self.bitmap.height, 0
      self.src_rect.set(@frame, 0, @w, @h)
    rescue
      self.bitmap = Bitmap.new(10, 16)
      @w, @h = self.bitmap.width, self.bitmap.height
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
    update_src_rect
    return unless EFFECT_TYPE
    case @effect[0] += 1
    when 1..7  then @effect[EFFECT_TYPE] += 1
    when 8..14 then @effect[EFFECT_TYPE] -= 1
    else @effect[0] = 0 end
  end
  #--------------------------------------------------------------------------
  # ● 更新源矩形
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @w == self.bitmap.width
    sx = (@frame += 1) % CURSOR_FRAME * @w
    self.src_rect.set(sx, 0, @w, @h)
  end
  #--------------------------------------------------------------------------
  # ● 更新可见性
  #--------------------------------------------------------------------------
  def update_visibility
    self.visible = @window.visible
    self.visible = @window.openness > 250
    self.opacity += @window.active ? 45 : -45
    self.opacity = 0 if @window.index < 0
  end
  #--------------------------------------------------------------------------
  # ● 更新位置
  #--------------------------------------------------------------------------
  def update_position
    rect = @window.cursor_rect
    self.z = @window.z + 100
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
  def initialize(*args)
    cursor_sprite_initialize(*args)
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