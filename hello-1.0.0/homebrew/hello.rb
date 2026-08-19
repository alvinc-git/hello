class Hello < Formula
  desc "Standard Hello program in C, Rust, and Go"
  homepage "https://github.com/alvinc-git/hello"
  url "https://github.com/alvinc-git/hello/releases/download/v1.0.0/hello-1.0.0.tar.xz"
  sha256 "SKIP_FOR_LOCAL_BUILD"
  license "MIT"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "rust" => :build
  depends_on "go" => :build

  def install
    system "./autogen.sh"
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    assert_match "Hello, World!", shell_output("#{bin}/hello")
    assert_match "Hello, World!", shell_output("#{bin}/hello_rust")
    assert_match "Hello, World!", shell_output("#{bin}/hello_go")
  end
end
