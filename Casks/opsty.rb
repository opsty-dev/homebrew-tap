# ============================================================
# opsty.rb — the Homebrew cask for Opsty
# ============================================================
# WHY THIS EXISTS   2026-10-18, review "Ready to Show" (H1). Opsty is
#                   installed from its own tap,
#                   github.com/opsty-dev/homebrew-tap, by full name:
#                     brew install --cask opsty-dev/tap/opsty
#                   The full name is what lets Homebrew 6 trust this one cask
#                   without a separate `brew tap` or `brew trust`.
#                   TRADEMARK.md already allows "a Homebrew cask … keeping
#                   the name". This file is the tap's seed: bump-cask.sh
#                   copies it to Casks/opsty.rb the first time and from then
#                   on rewrites only version and sha256.
# WHAT IT DOES      Installs the notarised Apple-silicon DMG from
#                   dl.opsty.dev and tells Homebrew the app updates itself.
# WHAT IT CANNOT DO Follow a beta channel (there is none), or undo the two
#                   things Opsty changes only on a click: Opsty as the app for
#                   ssh:// and x-man-page:// links (a Launch Services setting)
#                   and the `sudo ln` that puts the `opsty` command in
#                   /usr/local/bin from Settings.
# VERSION, SHA256   Set at each release by release-mac.sh step 7
#                   (bump-cask.sh), from the dmg's line in SHA256SUMS. A copy
#                   that says version 0.0.0 is the template kept beside
#                   Opsty's source, not the cask in the tap.
# THE NAME          Opsty is the name a person reads (`name`, the bundle
#                   Opsty.app); `opsty` is the token, the command, the files
#                   on dl.opsty.dev and every folder below — those never
#                   change case (electron-builder.yml, N1).
# ============================================================
cask "opsty" do
  version "0.7.0"
  sha256 "abace7d41e6eb23158d4dfecd9a5e9b5f40d50598991a77f04981f6f987c3ad0"

  url "https://dl.opsty.dev/releases/opsty-#{version}-arm64.dmg"
  name "Opsty"
  desc "Terminal that says what each tab is doing and what you left running"
  homepage "https://opsty.dev/"

  # The feed every installed copy reads. release-mac.sh uploads it last, after
  # the files it names, so livecheck never sees a version whose DMG is missing.
  livecheck do
    url "https://dl.opsty.dev/releases/latest-mac.yml"
    strategy :electron_builder
  end

  # electron-updater + Squirrel.Mac from dl.opsty.dev: `brew upgrade` leaves it
  # alone, `brew upgrade --greedy` replaces it.
  auto_updates true
  # Apple silicon only since 0.2.0 (2026-09-26); LSMinimumSystemVersion 13.0.0.
  # The bare symbol means "this release or newer".
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Opsty.app"
  # The `opsty [dir]` script (Contents/Resources/bin/opsty): it hands the
  # folder to the app with `open -b dev.opsty.opsty`, so a symlink works.
  binary "#{appdir}/Opsty.app/Contents/Resources/bin/opsty"

  # No `uninstall quit:` on purpose. Opsty is a terminal: brew is often run
  # inside it, and quitting it would end the shell running the upgrade (and
  # every other tab). macOS lets the bundle be replaced while it runs; the
  # running copy carries on until the person quits it.

  # Everything Opsty keeps (README ▸ Privacy). ~/.config/opsty is
  # $XDG_CONFIG_HOME/opsty when that is set; zap cannot follow it there.
  # No Keychain item: Opsty stores no secrets (no "opsty Safe Storage" exists).
  # The Quick Action is listed under both names: copies installed before
  # 0.7.0 are "New opsty Tab Here", and a case-sensitive volume keeps both.
  zap trash: [
    "~/.config/opsty",
    "~/Library/Application Support/opsty",
    "~/Library/Caches/dev.opsty.opsty",
    "~/Library/Caches/dev.opsty.opsty.ShipIt",
    "~/Library/Caches/opsty-updater",
    "~/Library/HTTPStorages/dev.opsty.opsty",
    "~/Library/Preferences/dev.opsty.opsty.plist",
    "~/Library/Saved Application State/dev.opsty.opsty.savedState",
    "~/Library/Services/New Opsty Tab Here.workflow",
    "~/Library/Services/New opsty Tab Here.workflow",
  ]
end
