class Minisatip < Formula
  desc "SAT>IP server with HDHomeRun emulation, userspace DVB drivers, and macOS support"
  homepage "https://github.com/rado0x54/minisatip"
  version "0.1.3"
  license "GPL-2.0-or-later"

  # The release binary is built with libdvbcsa, libsrt, libhdhomerun, and
  # OpenSSL statically linked (see .github/workflows/userspace-dvb-binaries.yml
  # in the upstream repo). Only system libs (libSystem, libc++) are dynamic,
  # so no `depends_on` is needed here.

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-arm64-darwin.zip"
      sha256 "c98e5fb87989b6a98710973e702b67f69fd7f5594daf5bd109028c01b83f469d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-aarch64-linux.zip"
      sha256 "06a722148c4381f854ae0a907c2f70d6d5830e81d4b8fd5d7f8007cb2d0840a6"
    end
    on_intel do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-x86_64-linux.zip"
      sha256 "7b23e104d7e1450153099353546597edffdab68ff793ca77c51627c2a3cecd27"
    end
  end

  def install
    bin.install "minisatip"
    pkgshare.install "html"
    # The release zip ships a firmware/README.txt explaining where to
    # source DVB chip-driver blobs. Install that as a docs reference;
    # don't ship the directory itself — users who need DVB firmware
    # manage it under var/, which survives brew upgrade.
    doc.install "firmware/README.txt" => "firmware-README.txt"
    (var/"lib/minisatip/firmware").mkpath
    (var/"cache/minisatip").mkpath
  end

  def caveats
    <<~EOS
      Web UI assets are installed at:
        #{opt_pkgshare}/html

      Firmware blobs for userspace DVB hardware go in:
        #{var}/lib/minisatip/firmware  (preserved across brew upgrade)

      See #{opt_share}/doc/minisatip/firmware-README.txt for blob sources.

      The launchd service binds non-privileged ports (no sudo required):
        HTTP/UI: http://localhost:9080
        RTSP:    rtsp://localhost:9554

      Run as a launchd service (paths + ports baked in):

        brew services start minisatip

      Or run directly:

        minisatip -R #{opt_pkgshare}/html \\
          --firmware-dir #{var}/lib/minisatip/firmware \\
          --cache-dir #{var}/cache/minisatip \\
          -x 9080 -y 9554

      If your SAT>IP client doesn't auto-discover via SSDP, point it at
      port 9554 (RTSP) directly. Override with -x / -y as needed.
    EOS
  end

  service do
    # -f / --foreground is mandatory under launchd: minisatip's default
    # is to fork-and-detach, which would orphan the daemon and make
    # launchctl think the service exited cleanly (so KeepAlive can't
    # restart it). With -f, the process launchd spawned IS the daemon.
    run [
      opt_bin/"minisatip",
      "-f",
      "-R", opt_pkgshare/"html",
      "--firmware-dir", var/"lib/minisatip/firmware",
      "--cache-dir", var/"cache/minisatip",
      "-x", "9080",
      "-y", "9554"
    ]
    keep_alive true
    log_path var/"log/minisatip.log"
    error_log_path var/"log/minisatip.err.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/minisatip --version 2>&1")
  end
end
