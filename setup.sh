#!/usr/bin/env bash
# Set up a WILDS development tree around this repo:
#
#   <top>/workspace           this repo (workspace file, this script)
#   <top>/<name>              the project repos (GitHub wilds-<name>), cloned here if missing
#   <top>/.venv               one shared venv with every package installed editable
#
# Safe to re-run: existing clones are left alone and the install is idempotent.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
top="$(dirname "$here")"
org="https://github.com/The-WILDS-Project"
repos=(bridge control gui science-camera solving claude)

for r in "${repos[@]}"; do
  if [[ -d "$top/$r/.git" ]]; then
    echo "present  $r"
  else
    git clone "$org/wilds-$r.git" "$top/$r"
  fi
done

command -v uv >/dev/null || { echo "uv is required: https://docs.astral.sh/uv/" >&2; exit 1; }

cd "$top"
[[ -x .venv/bin/python ]] || uv venv --python 3.14 .venv

# --no-sources: science-camera points sdss-archon at ../archon, which is not part of
# this tree, so archon comes from PyPI instead. claude holds notes, not a package.
uv pip install --no-sources --python .venv/bin/python \
  -e ./bridge -e ./solving -e ./control -e ./gui -e ./science-camera \
  sdss-archon pytest pytest-asyncio ruff xmlschema

echo
echo "Done. Open $here/WILDS.code-workspace in VS Code."
