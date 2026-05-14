class Minisatip < Formula
  desc "SAT>IP server with HDHomeRun emulation, userspace DVB drivers, and macOS support"
  homepage "https://github.com/rado0x54/minisatip"
  version "0.1.2"
  license "GPL-2.0-or-later"

  # The release binary is built with libdvbcsa, libsrt, libhdhomerun, and
  # OpenSSL statically linked (see .github/workflows/userspace-dvb-binaries.yml
  # in the upstream repo). Only system libs (libSystem, libc++) are dynamic,
  # so no `depends_on` is needed here.

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-arm64-darwin.zip"
      sha256 "19c478028a2c693f16faa8f66827f4fca9fdfb8d2da1160f0b3b65da959ac221"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-aarch64-linux.zip"
      sha256 "edb17ac410b10249a23b5c25480088602ceb0e75a1c98463deb9f85c71a1d7f5"
    end
    on_intel do
      url "https://github.com/rado0x54/minisatip/releases/download/v#{version}/minisatip-userspace-dvb-x86_64-linux.zip"
      sha256 "51c55da573f1237e8f018bcba41e38c408e9d5293959fcce61826015265c1a5b"
    end
  end

  def install
    bin.install "build/minisatip"
    pkgshare.install "html"
    # The release zip ships a firmware/README.txt explaining where to
    # source DVB chip-driver blobs. Install that as a docs reference;
    # don't ship the directory itself — users who need DVB firmware
    # manage it under var/, which survives brew upgrade.
    doc.install "firmware/README.txt" => "firmware-README.txt"
    (var/"lib/minisatip/firmware").mkpath
  end

  def caveats
    <<~EOS
      Web UI assets are installed at:
        #{opt_pkgshare}/html

      Firmware blobs for userspace DVB hardware go in:
        #{var}/lib/minisatip/firmware  (preserved across brew upgrade)

      See #{opt_share}/doc/minisatip/firmware-README.txt for blob sources.

      Run as a launchd service (web UI + firmware path baked in):

        brew services start minisatip

      Or run directly:

        FIRMWARE_DIR=#{var}/lib/minisatip/firmware \\
          minisatip -R #{opt_pkgshare}/html
    EOS
  end

  service do
    run [opt_bin/"minisatip", "-R", opt_pkgshare/"html"]
    environment_variables FIRMWARE_DIR: var/"lib/minisatip/firmware"
    keep_alive true
    log_path var/"log/minisatip.log"
    error_log_path var/"log/minisatip.err.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/minisatip --version 2>&1")
  end
end
