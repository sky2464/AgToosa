# AgToosa Homebrew Formula
# This file is maintained in the sky2464/AgToosa repo and mirrored to
# the sky2464/homebrew-agtoosa tap. Release automation should replace
# the branch source with a tagged tarball and concrete sha256 when the
# release artifact is publicly available.

class Agtoosa < Formula
  desc "Spec-driven agentic AI framework generator for software development"
  homepage "https://github.com/sky2464/AgToosa"
  url "https://github.com/sky2464/AgToosa.git", branch: "main"
  license "MIT"
  version "5.2.5"

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
