class ShellwatchAgent < Formula
  desc "Thin SSH agent proxy for ShellWatch — system SSH clients use ShellWatch-managed keys"
  homepage "https://github.com/rado0x54/ShellWatch"
  version "0.0.1"

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-arm64"
      sha256 "9cf6cf63eac416811688866e3a513fa34750b1b92965d3fd2936b38936aa6301"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-amd64"
      sha256 "78b2abc2c821c5a8f2e65dcfaf20ef8fe7832d0be84defe3b0d5b9d468981c40"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-arm64"
      sha256 "340982736c6cb9e61d226090f5e5115403fede191f40c32fc4e2450d926a47ba"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-amd64"
      sha256 "1827f0eab0203ea1ad05cba6d45f5818a5e77fd0cb7502acd0c02db68fc62310"
    end
  end

  def install
    # The release artifact is the bare binary named per-platform; rename
    # to `shellwatch-agent` on install so the on-disk binary matches what
    # users (and the service block below) expect.
    binary = Dir["shellwatch-agent-*"].first
    bin.install binary => "shellwatch-agent"
  end

  def caveats
    <<~EOS
      Authorize this device against your ShellWatch instance:

        shellwatch-agent login

      then start the daemon:

        brew services start shellwatch-agent

      and tell your shell where the socket is (~/.zshrc or ~/.bashrc):

        eval "$(shellwatch-agent --print-env)"

      The token is stored in your OS keyring (or a 0600 file fallback);
      no plaintext API key in the launchd plist.
    EOS
  end

  service do
    run [opt_bin/"shellwatch-agent"]
    keep_alive true
    log_path var/"log/shellwatch-agent.log"
    error_log_path var/"log/shellwatch-agent.err.log"
  end

  test do
    assert_match "shellwatch-agent", shell_output("#{bin}/shellwatch-agent help")
    assert_match version.to_s, shell_output("#{bin}/shellwatch-agent version")
  end
end
