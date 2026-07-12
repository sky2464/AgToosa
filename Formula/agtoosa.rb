# AgToosa Homebrew Formula
# This file is maintained in the sky2464/AgToosa repo and mirrored to
# the sky2464/homebrew-agtoosa tap. The source is pinned to a tagged
# release tarball with a concrete sha256 — release automation must bump
# url/sha256/version together on every release.

class Agtoosa < Formula
  desc "Spec-driven agentic AI framework generator for software development"
  homepage "https://github.com/sky2464/AgToosa"
  url "https://github.com/sky2464/AgToosa/archive/refs/tags/v5.3.10.tar.gz"
  sha256 "6a58afff051341f53fe00a1a9f61f00295c80bd916abbf629997efabfc50d31a"
  license "MIT"
  version "5.3.10"

  def install
    bin.install "agtoosa.sh" => "agtoosa"
    pkgshare.install "template"
    pkgshare.install "lib"
  end

  def caveats
    <<~EOS
      To scaffold AgToosa into a project, run:
        agtoosa

      On first run you will be prompted for the project path and AI platform.
    EOS
  end

  test do
    output = shell_output("#{bin}/agtoosa --version 2>&1")
    assert_match version.to_s, output
  end
end
