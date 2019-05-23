class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_pyqt_linked }

  def core_pyqt_linked
    Formula["pyqt"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink pyqt\e[0m or remove with brew \e[32muninstall --ignore-dependencies pyqt\e[0m\n\n" if core_pyqt_linked
    s
  end
end


class PyqtAT512 < Formula
  desc "Python bindings for v5 of Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/download5"
  url "https://www.riverbankcomputing.com/static/Downloads/PyQt5/5.12.2/PyQt5_gpl-5.12.2.tar.gz"
  sha256 "c565829e77dc9c281aa1a0cdf2eddaead4e0f844cbaf7a4408441967f03f5f0f"

  revision 1

  option "with-debug", "Build with debug symbols"
  option "with-docs", "Install HTML documentation and python examples"

  deprecated_option "enable-debug" => "with-debug"

  # keg_only "pyqt" is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "qt"
  depends_on "gsong2014/tools/sip@4.19"
  depends_on "python" => :recommended
  depends_on "python@2" => :recommended
  depends_on "dbus" => :optional

  # patch do
  #   url "https://raw.githubusercontent.com/gsong2014/homebrew-sdr/master/patch/"
  #   sha256 "525064e51ad77c2a905e6af0750ba17daa582daae9d9f873cae26b4bc8c087dd"
  # end

  def install
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--stubsdir=#{lib}/python#{version}/site-packages/PyQt5",
              "--sipdir=#{share}/sip/Qt5",
              # sip.h could not be found automatically
              "--sip-incdir=#{Formula["sip@4.19"].opt_include}",
              "--qmake=#{Formula["qt"].bin}/qmake",
              # Force deployment target to avoid libc++ issues
              "QMAKE_MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
              "--qml-plugindir=#{pkgshare}/plugins",
              "--verbose",
              "--sip=#{Formula["sip@4.19"].opt_bin}/sip",
              #  ERROR: Unknown module(s) in QT
              "--disable=QtWebKit",
              "--disable=QtWebKitWidgets",
              "--disable=QAxContainer",
              "--disable=QtX11Extras",
              "--disable=QtWinExtras",
              "--disable=Enginio",
              "--no-dist-info"]
              
      args << "--debug" if build.with? "debug"

      system python, "configure.py", *args
      system "make"
      system "make", "install"
      system "make", "clean"
    end
    doc.install "doc/html", "examples" if build.with? "docs"
  end

  test do
    system "#{bin}/pyuic5", "--version"
    system "#{bin}/pylupdate5", "-version"
    
    ["#{Formula["python@2"].opt_bin}/python2", "#{Formula["python"].opt_bin}/python3"].each do |python|
      version = Language::Python.major_minor_version python
      ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
      system python, "-c", "import PyQt5"
      %w[
        Gui
        Location
        Multimedia
        Network
        Quick
        Svg
        WebEngineWidgets
        Widgets
        Xml
      ].each { |mod| system python, "-c", "import PyQt5.Qt#{mod}" }
    end
  end
end
