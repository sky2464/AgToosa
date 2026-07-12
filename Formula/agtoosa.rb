# AgToosa Homebrew Formula
# This file is maintained in the sky2464/AgToosa repo and mirrored to
# the sky2464/homebrew-agtoosa tap. The source is pinned to a tagged
# release tarball with a concrete sha256 — release automation must bump
# url/sha256/version together on every release.

class Agtoosa < Formula
  desc "Spec-driven agentic AI framework generator for software development"
  homepage "https://github.com/sky2464/AgToosa"
  url "https://github.com/sky2464/AgToosa/archive/refs/tags/v5.3.11.tar.gz"
  sha256 "9a729dbcf4b6ce42c02e9cef9a95ac8b511a283e26a5aee91d8c21d7da376041"
  license "MIT"
  version "5.3.11"

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
