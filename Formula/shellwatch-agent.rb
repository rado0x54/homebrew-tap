class ShellwatchAgent < Formula
  desc "Thin SSH agent proxy for ShellWatch — system SSH uses ShellWatch keys"
  homepage "https://github.com/rado0x54/ShellWatch"
  version "1.0.0"

  on_macos do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-arm64"
      sha256 "5f525a63311b111cbcedd06b011f8ed04cdc8fff9a042e4c08eddcb2ecd02c3c"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-darwin-amd64"
      sha256 "8cc4309c566f9db58510f855dcedc6a925f4464f1d2ac549e264c57ade9347af"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-arm64"
      sha256 "89e13982d2111c93891804b51c73d767ffbebc143885dc946b7c9348a2a9d9a6"
    end
    on_intel do
      url "https://github.com/rado0x54/ShellWatch/releases/download/agent/v#{version}/shellwatch-agent-linux-amd64"
      sha256 "788354fc67254040f4a976c2082a44fb3259acb9862e8377df5ba7831a76a590"
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
