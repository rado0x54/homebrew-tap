class ShellwatchAgent < Formula
  desc "Thin SSH agent proxy for ShellWatch — system SSH uses ShellWatch keys"
  homepage "https://github.com/rado0x54/ShellWatch"
  version "1.2.0"

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-arm64"
      sha256 "3528039ea43c139b9e72c561d500492f3783f7b6fc5381260fbabfd35282831a"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-amd64"
      sha256 "5336fa67f0450ae2d3ef543100d654497a863b238cd7348c84c14da018de782b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-arm64"
      sha256 "4b12f109a2da32abafb0fa1b5f2f729cedeadfc536b7ee6739021131a2bb7a90"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-amd64"
      sha256 "80c4a861b146e4fd81b501d06dc8e1671accd4172f4eacf917104f1ca96f3240"
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
