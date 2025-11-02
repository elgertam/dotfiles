cask "quickbooks-online" do
  version :latest
  sha256 :no_check

  url "https://http-download.intuit.com/http.intuit/CMO/tango/static/latest/QuickBooks%20Online.dmg"
  name "QuickBooks Online"
  desc "Desktop application for QuickBooks Online"
  homepage "https://quickbooks.intuit.com/"

  livecheck do
    skip "Version cannot be determined"
  end

  app "QuickBooks Online.app"

  zap trash: [
    "~/Library/Application Support/QuickBooks Online",
    "~/Library/Caches/com.intuit.QuickBooksOnline",
    "~/Library/Preferences/com.intuit.QuickBooksOnline.plist",
    "~/Library/Saved Application State/com.intuit.QuickBooksOnline.savedState",
  ]
end
