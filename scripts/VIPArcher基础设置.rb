module VIPArcher
  #--------------------------------------------------------------------------
  # ● 需要的 Windows API 函数
  #--------------------------------------------------------------------------
  GetWindowThreadProcessId = Win32API.new('user32',   'GetWindowThreadProcessId', 'lp',  'l')
  GetWindow                = Win32API.new('user32',   'GetWindow',                'll',  'l')
  GetClassName             = Win32API.new('user32',   'GetClassName',             'lpl', 'l')
  GetWindowText            = Win32API.new('user32',   'GetWindowText',            'lpl', 'l')
  GetCurrentThreadId       = Win32API.new('kernel32', 'GetCurrentThreadId',       'V',   'l')
  GetForegroundWindow      = Win32API.new('user32',   'GetForegroundWindow',      'V',   'l')
  ShellExecuteA            = Win32API.new('shell32',  'ShellExecuteA',         'pppppi', 'i')
  #--------------------------------------------------------------------------
  # ● 获取窗口句柄 by: 紫苏 
  #--------------------------------------------------------------------------
  def self.get_window_handle
    threadID = GetCurrentThreadId.call
    hWnd = GetWindow.call(GetForegroundWindow.call, 0)
    while hWnd != 0
      if threadID == GetWindowThreadProcessId.call(hWnd, 0)
        className = " " * 11
        GetClassName.call(hWnd, className, 12)
        break if className == "RGSS Player"
      end
      hWnd = GetWindow.call(hWnd, 2)
    end
    return hWnd
  end
  #--------------------------------------------------------------------------
  # ● 打开地址
  #     VIPArcher.open_url(addr)
  #--------------------------------------------------------------------------
  def self.open_url(addr)
    ShellExecuteA.call(0,'open',addr,0, 0, 1)
  end
end
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 获取事件显示的图片的 Bitmap 对象 不存在则返回 nil
  #--------------------------------------------------------------------------
  def get_bitmap(id = 0)
    spriteset = SceneManager.scene.instance_variable_get(:@spriteset)
    sprite = spriteset.instance_variable_get(:@picture_sprites)[id]
    sprite ? sprite.bitmap : nil
  end
end
#==============================================================================
# Game.ini 配置文件读取及设置
#==============================================================================
class IniFile
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_reader :filename
  #--------------------------------------------------------------------------
  # ● Win32API
  #--------------------------------------------------------------------------
  GetPrivateProfileString   = Win32API.new('kernel32','GetPrivateProfileString'  , 'ppppip', 'i')
  WritePrivateProfileString = Win32API.new('kernel32','WritePrivateProfileString', 'pppp'  , 'i')
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(filename = './Game.ini')
    @filename = filename
  end
  #--------------------------------------------------------------------------
  # ● 获取配置
  #--------------------------------------------------------------------------
  def [](section, key, default_value = '')
    l = GetPrivateProfileString.call(section, key, default_value, 
      buffer = [].pack('x256'), buffer.size, @filename); buffer[0, l]
  end
  #--------------------------------------------------------------------------
  # ● 设置配置
  #--------------------------------------------------------------------------
  def []=(section, key, value)
    WritePrivateProfileString.call(section, key, value.to_s, @filename)
  end
end
class String
  #--------------------------------------------------------------------------
  # ● 常量定义
  #--------------------------------------------------------------------------
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi',   'i')
  WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  Codepages = {
    :System => 0,     :UTF7   => 65000, :UTF8   => 65001,
    :S_JIS  => 932,   :GB2312 => 936,   :BIG5   => 950, 
  }
  #--------------------------------------------------------------------------
  # ● 伪 iconv 编码转换
  #--------------------------------------------------------------------------
  #     s : 原始编码，可使用 Codepages 中的符号或者直接使用代码页值。
  #     d : 目标编码，同上。
  #--------------------------------------------------------------------------
  def iconv s, d
    src  = s.is_a?(Symbol)? Codepages[s] : s
    dest = d.is_a?(Symbol)? Codepages[d] : d
    len = MultiByteToWideChar.call src, 0, self, -1, nil, 0
    buf = "\0" * (len * 2)
    MultiByteToWideChar.call src, 0, self, -1, buf, buf.size / 2
    len = WideCharToMultiByte.call dest, 0, buf, -1, nil, 0, nil, nil
    ret = "\0" * len
    WideCharToMultiByte.call dest, 0, buf, -1, ret, ret.size, nil, nil
    self.respond_to?(:force_encoding) ?
    ret.force_encoding("ASCII-8BIT").delete("\000") : ret.delete("\000")
  end
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 ANSI 转为 UTF-8 编码
  #--------------------------------------------------------------------------
  def s2u
    self.respond_to?(:force_encoding) ?
    iconv(:System, :UTF8).force_encoding("utf-8") : iconv(:System, :UTF8)
  end
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 UTF-8 转为 ANSI 编码
  #--------------------------------------------------------------------------
  def u2s
    iconv(:UTF8, :System)
  end
end
#--------------------------------------------------------------------------
# ● 备注的读取
#--------------------------------------------------------------------------
class RPG::BaseItem
  #--------------------------------------------------------------------------
  # ● 读取备注的基本方法
  #     note     : 备注文字
  #     default  : 缺省值
  #--------------------------------------------------------------------------
  def renote(note,default = nil)
    result = /<#{note}\s+(\S+)\s*>/ =~ @note ? $1 : default
    result
  end
end
class Bitmap
  #--------------------------------------------------------------------------
  # ● 由白色渐变到实际的字体颜色的渐变字
  #     level  : 渐变等级，值越高效果越差。效率越好。不可为 0
  #--------------------------------------------------------------------------
  def draw_gradient_text(x, y, w, h, str, align = 0, level = 1)
    buffer = Bitmap.new(w, h); buffer.font = font.dup;
    alpha = font.color.alpha; delta = alpha / h.to_f * level;
    buffer.font.outline = buffer.font.shadow = false
    buffer.font.color = Color.new(255, 255, 255); 
    draw_text(x, y, w, h, str, align); buffer.draw_text(0, 0, w, h, str, align)
    rect = Rect.new(0, 0, w, level)
    y.upto(y + h){ |n| next unless n % level == 0
      blt(x, n - 1, buffer, rect, alpha -= delta); rect.y += level
    }; buffer.dispose; self;
  end
end
