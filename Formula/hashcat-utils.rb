require 'formula'

class HashcatUtils < Formula
  homepage "http://hashcat.net/hashcat/"
  url "https://github.com/hashcat/hashcat-utils/releases/download/v1.8/hashcat-utils-1.8.7z"
  sha256 "37686f536ee5be3ad39fa25127f394d0accf41c63170482f87f39d2f9fcd00f5"
  head "https://github.com/hashcat/hashcat-utils.git"

  depends_on 'p7zip' => :build

  def install
    cd "hashcat-utils" do
      #inreplace "Makefile", /\/opt\/hashcat-toolchain\/linux32\/bin\/i686-hashcat-linux-gnu-gcc/, ENV.cc
      #inreplace "Makefile", /\$\(CFLAGS\) -m32/, '$(CFLAGS)'
      #system "make", "clean"
      #system "make", "posix"
      bin.install Dir["bin/*.bin"]
      bin.install Dir["bin/*.pl"]
    end
  end
end