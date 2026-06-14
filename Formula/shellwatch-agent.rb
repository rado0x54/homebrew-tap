class ShellwatchAgent < Formula
  desc "Thin SSH agent proxy for ShellWatch — system SSH uses ShellWatch keys"
  homepage "https://github.com/rado0x54/ShellWatch"
  version "1.1.0"

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-arm64"
      sha256 "2490675a46cbbd1ea0d769212ba4be1137140fb18fd7e4e81d97e42ffea57a78"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-amd64"
      sha256 "f19e2f48f491339f2ebae1fde874360d7f95e0f1b86dd98a57b4e5d8c55309aa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-arm64"
      sha256 "c3c0a86f2359e353a49fa2fdb7e921c4c10b752d85c7e3a85aaeeaa027acab64"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-amd64"
      sha256 "eac23f5ed367f7ede4179ab34e91c0d0dfda8250c59bb50eb16366ecdccc165a"
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
