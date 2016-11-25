#==============================================================================
# ■ 游戏版本检查 V2.0
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 httprm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
# ● 配置: 配置好下面的链接和版本信息，并把云端版本文件更新成和本脚本的版本一致
#    使用：脚本调用: Game_Version.check       进行版本检查
#    另外：脚本调用: VIPArcher.open_url("url") 可以打开链接为 url 的网页
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:version_check] = 20161125
module VIPArcher
  The_Current_Version = "1.1.1" # 当前游戏版本
  #--------------------------------------------------------------------------
  # ● 链接的设置
  #--------------------------------------------------------------------------
  # 官网主页
  Home_Url     = "http://house-of-lies.lofter.com/index"
  # 游戏下载链接
  Download_Url = "http://house-of-lies.lofter.com/download"
  # 云端版本号文件链接
  Version_Url  = "http://git.oschina.net/VIPArcher/Game/raw/master/version"
  # 云端版本更新内容文件链接
  Features_Url = "http://git.oschina.net/VIPArcher/Game/raw/master/features"
  #--------------------------------------------------------------------------
  # ● 用语的设置
  #--------------------------------------------------------------------------
  # 显示当前版本并询问是否更新的提示内容 (需要改动的话请只改动中间三行)
  #    %s 版本信息占位符  EOF 为创建多行字符串用的，头尾两个都尽量别动
  Current_Version_Hint = <<EOF
您当前的游戏版本为V%s，现在联网进行版本检查吗？
【提醒】：检查中游戏将出现无响应状况，请耐心等待，并确保网络连接正常。
【注意】：一般情况下新版本游戏仍然可以继承旧版本的Saves文件夹。
EOF
  # 当前已经是最新版本提示
  No_New_Version_Hint  = "恭喜！当前的游戏已是最新版本。\n祝您游戏愉快！"
  # 提示有新版本标题  %s 版本信息占位符
  New_Version_Title    = "已找到最新版V%s，立即访问官网下载更新补丁?"
  # 新版本提示(有新版本但没有找到更新内容是提示信息)
  New_Version_Hint     = "您可以访问游戏官网以查看最新版本更新内容。"
  # 检查失败提示 (这个提示很少会用到)
  Check_Failure_Hint   = "检查新版本失败！建议您可以访问游戏官网以查看最新版本信息。"
  #连接网络失败或者查询文件失败时提示 EOF 为创建多行字符串用的，头尾两个都尽量别动
  Could_Not_Connect = <<EOF
请确保网络链接正常！或者关闭防火墙、解除360拦截之类的。
如果你是在我本人提供的地址下载的本游戏，那么我也只能以
宅的名义确保本游戏的纯洁性！其他下载地址的概不负责~
EOF
  #--------------------------------------------------------------------------
  # ● 需要的 Windows API 函数
  #--------------------------------------------------------------------------
  MessageBoxW            = Win32API.new('user32', 'MessageBoxW',            'lppl',   'l')
  ShellExecuteA          = Win32API.new('shell32','ShellExecuteA'         , 'pppppi', 'i')
  URLDownloadToCacheFile = Win32API.new('Urlmon', 'URLDownloadToCacheFile', 'ippiii', 'i')
  #--------------------------------------------------------------------------
  # ● 打开地址
  #     VIPArcher.open_url(addr)
  #--------------------------------------------------------------------------
  def self.open_url(addr)
    ShellExecuteA.call(0,'open',addr,0, 0, 1)
  end
  #--------------------------------------------------------------------------
  # ● 呼出 MessageBoxW 对话框
  #    icon 图标 16 -> :error 32 -> :question 48 -> :warning 64 -> :information
  #    button    0 -> 确定 1 -> 确定 取消 2 中止 重试 忽略
  #              3 -> 是 否 取消          4 -> 是 否
  #    return    确定(1) 取消(2) 中止(3) 重试(4) 忽略(5) 是(6) 否(7)
  #--------------------------------------------------------------------------
  def self.callMessageBoxW(hint, title, icon, button,hWnd = 0)
    MessageBoxW.call(hWnd, hint.u2w, title.u2w, icon | button)
  end
end
#==============================================================================
# String类
#==============================================================================
class String
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 宽字符 转为 UTF-8
  #--------------------------------------------------------------------------
  def w2u
    self.unpack("S*").pack("U*").sub(/\0+$/, '')
  end
  #--------------------------------------------------------------------------
  # ● 快捷方式：从 UTF-8 转为 宽字符
  #--------------------------------------------------------------------------
  def u2w
    self.unpack("U*").pack("S*") + "\0\0"
  end
  #--------------------------------------------------------------------------
  # ● 强制编码
  #--------------------------------------------------------------------------
  def f_e
    self.force_encoding(__ENCODING__)
  end
end
module Game_Version
  class << self
  include VIPArcher
    #--------------------------------------------------------------------------
    # ● 获取版本 Game_Version.check
    #--------------------------------------------------------------------------
    def check
      hint = sprintf(Current_Version_Hint, The_Current_Version)
      return unless VIPArcher.callMessageBoxW(hint,"检查游戏版本更新",32,1) == 1
      return unless get_version
      if The_Current_Version == @version
        return VIPArcher.callMessageBoxW(No_New_Version_Hint,"已是最新版", 64,0)
      end
      features_title = sprintf(New_Version_Title, @version)
      hint = get_features ? @version_features : New_Version_Hint
      if VIPArcher.callMessageBoxW(hint, features_title, 64 , 1) == 1
        VIPArcher.open_url(Download_Url)
      end
    end
    #--------------------------------------------------------------------------
    # ● 获取版本
    #--------------------------------------------------------------------------
    def get_version
      begin
        URLDownloadToCacheFile.call(0, "#{Version_Url}?#{rand(10)}",
                buf = "\0" * 1024, 1024, 0, 0)
        if file = open(buf.sub(/\0+$/,''), 'rb'){ |p| p.read }
          @version = file.to_s
        else
          hint = "#{Check_Failure_Hint}\n地址：#{Home_Url}"
          if VIPArcher.callMessageBoxW(hint, "获取版本信息失败！", 64 , 4) == 6
             VIPArcher.open_url(Home_Url); return false
          end
        end
      rescue
        hint = "#{Could_Not_Connect}\n地址：#{Home_Url}"
        VIPArcher.callMessageBoxW(hint, "检查新版本失败！", 64 , 1)
        return false
      end
    end
    #--------------------------------------------------------------------------
    # ● 获取新版本更新内容
    #--------------------------------------------------------------------------
    def get_features
      begin
        URLDownloadToCacheFile.call(0, "#{Features_Url}?#{rand(10)}",
          buf = "\0" * 1024, 1024, 0, 0)
        if file = open(buf.sub(/\0+$/,''), 'rb'){ |p| p.read }
          @version_features = file.f_e
        end
      rescue
        return false
      end
    end
  end
end
