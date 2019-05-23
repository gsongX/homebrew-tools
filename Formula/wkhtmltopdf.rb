class Wkhtmltopdf < Formula
  desc "Convert HTML to PDF using Webkit (QtWebKit)"
  homepage "http://wkhtmltopdf.org"
  url "https://github.com/wkhtmltopdf/wkhtmltopdf/archive/0.12.5.tar.gz"
  sha256 "861d6e61e2f5beb2d8daaade2cd5a85b84065ee9fac0d6d85000d8a7712a4621"

  head "https://github.com/wkhtmltopdf/wkhtmltopdf.git"
  version "0.12.5"

  revision 1

  depends_on "qt5-webkit" => :build

  patch :p0 do
    url "https://raw.githubusercontent.com/gsong2014/homebrew-tools/master/patch/patch-src_image_image.pro-use-osx-loader-variable.diff"
    sha256 "78b109f018ad812b58ed6b7c959fcbc9e35a34fa84e661be09ebe8decd41ebeb"
  end

  # patch :p0 do
  #   url "https://raw.githubusercontent.com/gsong2014/homebrew-tools/master/patch/patch-src_lib_lib.pro-set-install-name.diff"
  #   sha256 "4fda2e96623199c5b1e1570472cb26ff5efa9e575c622dd972f3c58fb221ae44"
  # end

  patch :p0 do
    url "https://raw.githubusercontent.com/gsong2014/homebrew-tools/master/patch/patch-src_pdf_pdf.pro-use-osx-loader-variable.diff"
    sha256 "4aaf8b3d8e6b29404b06521db66fe1645f9d82f2311cdfd205a1244ac3067479"
  end

  def install
    ENV["WKHTMLTOX_VERSION"] = "0.12.5"

    # on Mavericks we want to target libc++, this requires a macx-clang flag
    spec = (ENV.compiler == :clang && MacOS.version >= :mavericks) ? "macx-clang" : "macx-g++"
    args = %W[-config release -spec #{spec}]

    system Formula["qt"].bin/"qmake", "../wkhtmltopdf.pro", "PREFIX=#{prefix}", *args
    system "make"
    system "make", "install"

    %w[dllbegin.inc dllend.inc image.h pdf.h].each do |a|
      (include/"wkhtmltox").install "include/wkhtmltox/#{a}"
    end
    bin.install Dir["bin/wkhtml*"]
    lib.install Dir["bin/*.dylib"]
  end
end