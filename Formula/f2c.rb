class F2c < Formula
  desc "Fortran-to-C Converter"
  homepage "http://www.netlib.org/f2c/"
  url "http://www.netlib.org/f2c/src.tgz"
  version "20200916"
  sha256 "d4847456aa91c74e5e61e2097780ca6ac3b20869fae8864bfa8dcc66f6721d35"

  resource "lib" do
    url "http://www.netlib.org/f2c/libf2c.zip"
    sha256 "ca404070e9ce0a9aaa6a71fc7d5489d014ade952c5d6de7efb88de8e24f2e8e0"
  end

  resource "manual" do
    url "http://www.netlib.org/f2c/f2c.pdf"
    sha256 "816cdbfd20ce3695be0eb976648714b6fe496785bb8026c6b8911712764d57c7"
  end

  def install
    cp 'makefile.u', 'makefile'
    system "make"
    bin.install 'f2c'
    man1.install "f2c.1t" => "f2c.1"
    resource("lib").stage do
      system "make", "-f", "makefile.u", "f2c.h"
      include.install "f2c.h"
      system "make", "-f", "makefile.u"
      lib.install "libf2c.a"
    end
    resource("manual").stage do
      doc.install 'f2c.pdf'
    end
  end

end
