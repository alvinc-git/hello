# macOS Homebrew Packaging for hello

This directory contains the Homebrew formula packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/homebrew/`) alongside other distribution frameworks.

## Contents

- `Formula/hello.rb` & `hello.rb`: Standard Homebrew formula specifying upstream source release archives, build-time dependencies (`autoconf`, `automake`, `rust`), Autotools configure/make targets, and test assertions.
- `README.md`: This guide.

## Prerequisites

On macOS:
- [Homebrew](https://brew.sh/) installed
- Xcode Command Line Tools (`xcode-select --install`)

## Automated Build & Audit Script

Run the automated verification script from repository root:

```bash
./ci/build-homebrew.sh
```

## Manual Installation & Testing

```bash
# 1. Test the formula locally
brew install --build-from-source hello-1.0.0/homebrew/Formula/hello.rb

# 2. Run formula audit
brew audit --strict hello-1.0.0/homebrew/Formula/hello.rb

# 3. Run formula tests
brew test hello-1.0.0/homebrew/Formula/hello.rb
```

## Adding to a Custom Tap

To distribute via a custom tap (e.g. `alvinc-git/tap`):

```bash
# Create or clone homebrew-tap repository
git clone git@github.com:alvinc-git/homebrew-tap.git

# Copy Formula into tap
cp hello-1.0.0/homebrew/Formula/hello.rb homebrew-tap/Formula/

# Users can now install with:
brew tap alvinc-git/tap
brew install hello
```
