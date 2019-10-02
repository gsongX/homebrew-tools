class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.2.1.tar.xz"
  sha256 "cec7c87e9b60d174509e263ac4011b522385fd0775292e1670ecc1180c9bb6d4"
  revision 1
  head "https://github.com/FFmpeg/FFmpeg.git"

  option "with-chromaprint", "Enable the Chromaprint audio fingerprinting library"
  option "with-fdk-aac", "Enable the Fraunhofer FDK AAC library"
  option "with-libssh", "Enable SFTP protocol via libssh"
  option "with-openh264", "Enable OpenH264 library"
  option "with-openssl", "Enable SSL support"
  option "with-srt", "Enable SRT library"
  option "with-libvmaf", "Enable libvmaf scoring library"


  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "texi2html" => :build

  depends_on "lame"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "opus"
  depends_on "sdl2"
  depends_on "snappy"
  depends_on "theora"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"
  depends_on "aom"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "libass"
  depends_on "libsoxr"
  depends_on "speex"
  depends_on "openjpeg"
  depends_on "rtmpdump"
  depends_on "libbluray"
  depends_on "rubberband"
  depends_on "webp"
  depends_on "zeromq"
  depends_on "zimg"
  depends_on "libbs2b"
  depends_on "libcaca"
  depends_on "libgsm"
  depends_on "libmodplug"
  depends_on "librsvg"
  depends_on "tesseract"
  depends_on "opencore-amr"
  depends_on "libvidstab"
  depends_on "openssl"

  depends_on "chromaprint" => :optional
  depends_on "fdk-aac" => :optional
  depends_on "game-music-emu" => :optional
  depends_on "libssh" => :optional
  depends_on "libvmaf" => :optional
  depends_on "openh264" => :optional
  depends_on "srt" => :optional
  depends_on "two-lame" => :optional
  depends_on "wavpack" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --enable-hardcoded-tables
      --enable-avresample
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gpl
      --enable-libmp3lame
      --enable-libopus
      --enable-libsnappy
      --enable-libtheora
      --enable-libvorbis
      --enable-libvpx
      --enable-libx264
      --enable-libx265
      --enable-libxvid
      --enable-lzma
      --enable-libfontconfig
      --enable-libfreetype
      --enable-frei0r
      --enable-libass
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-librtmp
      --enable-libspeex
      --disable-libjack
      --disable-indev=jack
      --enable-libaom
      --enable-libsoxr
      --enable-libbluray
      --enable-librubberband
      --enable-libwebp
      --enable-libzimg
      --enable-libzmq
      --enable-libgsm
      --enable-libbs2b
      --enable-libcaca
      --enable-libmodplug
      --enable-librsvg
      --enable-libtesseract
      --enable-libvidstab
      --enable-openssl
    ]

    args << "--enable-chromaprint" if build.with? "chromaprint"
    args << "--enable-libfdk-aac" if build.with? "fdk-aac"
    args << "--enable-libgme" if build.with? "game-music-emu"
    args << "--enable-libopenh264" if build.with? "openh264"
    args << "--enable-libsrt" if build.with? "srt"
    args << "--enable-libssh" if build.with? "libssh"
    args << "--enable-libtwolame" if build.with? "two-lame"
    args << "--enable-libvmaf" if build.with? "libvmaf"
    args << "--enable-libwavpack" if build.with? "wavpack"
    args << "--enable-opencl" if MacOS.version > :lion
    args << "--enable-videotoolbox" if MacOS.version >= :mountain_lion

    if build.with? "openjpeg"
      args << "--enable-libopenjpeg"
      args << "--disable-decoder=jpeg2000"
      args << "--extra-cflags=" + `pkg-config --cflags libopenjp2`.chomp
    end

    # These librares are GPL-incompatible, and require ffmpeg be built with
    # the "--enable-nonfree" flag, which produces unredistributable libraries
    args << "--enable-nonfree" if build.with?("fdk-aac") || build.with?("openssl")

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
