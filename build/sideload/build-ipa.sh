#!/bin/bash
set -euo pipefail

# This script lives in <Msea>/build/sideload. Optional first argument: project root.
script_dir="$(cd "$(dirname "$0")" && pwd)"
project_root="${1:-$(cd "$script_dir/../.." && pwd)}"
project_root="$(cd "$project_root" && pwd)"
out="$project_root/build/sideload"
source_dir="$out/Source"

if [[ ! -f "$project_root/Msea.xcodeproj/project.pbxproj" ]]; then
  echo 'Msea.xcodeproj not found in the project root.' >&2
  exit 1
fi
mkdir -p "$source_dir"

# Build in a copy because the project's SwiftLint build phase uses --fix.
/usr/bin/rsync -a --delete \
  --exclude '.git/' --exclude 'build/' --exclude 'DerivedData/' \
  --exclude 'xcuserdata/' --exclude '.build/' --exclude '.DS_Store' \
  "$project_root/" "$source_dir/"

if ! /usr/bin/xcodebuild \
  -workspace "$source_dir/Msea.xcworkspace" \
  -scheme Msea \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$out/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' \
  build > "$out/build.log" 2>&1; then
  tail -n 60 "$out/build.log" >&2
  exit 1
fi

app="$out/DerivedData/Build/Products/Release-iphoneos/Msea.app"
[[ -f "$app/Msea" ]] || { echo 'Build did not produce Msea.app.' >&2; exit 1; }

# Xcode wraps the statically linked UMeng libraries in stub dynamic frameworks that
# the executable never loads (no @rpath load command). Third-party re-signers sign
# those stubs inconsistently and iOS then rejects the whole bundle with 0xe8008017.
if /usr/bin/otool -L "$app/Msea" | /usr/bin/grep -q '@rpath/'; then
  echo 'The executable loads @rpath frameworks; refusing to strip Frameworks/.' >&2
  exit 1
fi
/bin/rm -rf "$app/Frameworks"

staging="$(mktemp -d "$out/package.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/Payload"
/usr/bin/ditto "$app" "$staging/Payload/Msea.app"
(
  cd "$staging"
  /usr/bin/zip -qry Msea-unsigned.ipa Payload
)
/usr/bin/unzip -tq "$staging/Msea-unsigned.ipa"
/bin/mv -f "$staging/Msea-unsigned.ipa" "$out/Msea-unsigned.ipa"
echo "Created: $out/Msea-unsigned.ipa"
echo 'Unsigned IPA: the recipient must re-sign it with their own Apple Account before installation.'
