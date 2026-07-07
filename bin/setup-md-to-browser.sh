#!/usr/bin/env bash
mkdir -p "$HOME/.local/bin"
cp "$(dirname "$0")/md-to-browser" "$HOME/.local/bin/md-to-browser"
chmod +x "$HOME/.local/bin/md-to-browser"

if ! command -v pandoc &> /dev/null; then
    brew install pandoc
fi

if ! command -v duti &> /dev/null; then
    brew install duti
fi

mkdir -p "$HOME/Applications"
osacompile -o "$HOME/Applications/MDToBrowser.app" <<'EOF'
on open theFiles
	repeat with theFile in theFiles
		do shell script "/Users/soroqn/.local/bin/md-to-browser " & quoted form of (POSIX path of theFile)
	end repeat
end open
EOF

plutil -insert CFBundleIdentifier -string "com.soroqn.md-to-browser" "$HOME/Applications/MDToBrowser.app/Contents/Info.plist"

python3 -c "
import plistlib, os
plist_path = os.path.expanduser('~/Applications/MDToBrowser.app/Contents/Info.plist')
with open(plist_path, 'rb') as f:
    pl = plistlib.load(f)
pl['CFBundleDocumentTypes'] = [
    {
        'CFBundleTypeExtensions': ['md', 'markdown'],
        'CFBundleTypeName': 'Markdown Document',
        'CFBundleTypeRole': 'Editor',
        'LSItemContentTypes': ['net.daringfireball.markdown', 'public.markdown']
    }
]
with open(plist_path, 'wb') as f:
    plistlib.dump(pl, f)
"

/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f "$HOME/Applications/MDToBrowser.app"
open "$HOME/Applications/MDToBrowser.app"
sleep 1
duti -s com.soroqn.md-to-browser net.daringfireball.markdown all
duti -s com.soroqn.md-to-browser md all
duti -s com.soroqn.md-to-browser markdown all
