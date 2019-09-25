class WxpythonAT4 < Formula
  desc "Python bindings for wxWidgets"
  homepage "https://www.wxwidgets.org/"
  url "https://github.com/wxWidgets/Phoenix/archive/wxPython-4.0.6.tar.gz"
  sha256 "d54129e5fbea4fb8091c87b2980760b72c22a386cb3b9dd2eebc928ef5e8df61"
  revision 1

  depends_on "python@2"
  depends_on "python"
  depends_on "wxmac@3.1"

  def install
    ENV["WXWIN"] = buildpath
    ENV.append_to_cflags "-arch #{MacOS.preferred_arch}"

    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python

    # wxPython is hardcoded to install headers in wx's prefix;
    # set it to use wxPython's prefix instead
    # See #47187.
    inreplace %w[wxPython/config.py wxPython/wx/build/config.py],
      "WXPREFIX +", "'#{prefix}' +"

    args = [
      "WXPORT=osx_cocoa",
      # Reference our wx-config
      "WX_CONFIG=#{Formula["wxmac@3.1"].opt_bin}/wx-config",
      # At this time Wxmac is installed Unicode only
      "UNICODE=1",
      # Some scripts (e.g. matplotlib) expect to `import wxversion`, which is
      # only available on a multiversion build.
      "INSTALL_MULTIVERSION=1",
      # OpenGL and stuff
      "BUILD_GLCANVAS=1",
      "BUILD_GIZMOS=1",
      "BUILD_STC=1",
    ]

    cd "wxPython" do
      system python, "build.py", "install", "--prefix=#{prefix}", *args
    end
  end

  test do
    output = shell_output("python -c 'import wx ; print wx.version()'")
    assert_match version.to_s, output
  end
end
