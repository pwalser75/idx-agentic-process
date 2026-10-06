#!/usr/bin/env bash
#
# iap.sh — fast, read-only helper for the idx Agentic Process (IAP).
#
# IAP keeps its state as Markdown under spec/. This helper gives an agent a
# single-pass view of that state, so it can run one command instead of opening
# every ticket or requirement file. It never writes anything.
#
# Usage:
#   iap.sh headers            all ticket headers: ID  STATUS  TYPE  TITLE  CREATED, oldest first
#   iap.sh open               like headers, but without CLOSED tickets
#   iap.sh list STATUS...     open-ish headers filtered by status, e.g. list DRAFT READY
#   iap.sh next               highest-priority READY ticket (BUG > IMPROVEMENT > STORY, then oldest)
#   iap.sh counts             ticket count per status
#   iap.sh find PATTERN       ticket files whose name contains PATTERN
#   iap.sh inferred           requirement/architecture files marked "origin: inferred"
#   iap.sh preconditions      process commands whose preconditions are currently met
#   iap.sh help
#
# The spec root defaults to ./spec; override it with IAP_SPEC=/path/to/spec.
#
set -euo pipefail

SPEC="${IAP_SPEC:-spec}"

usage() {
  cat <<'EOF'
iap.sh — read-only helper for the idx Agentic Process (IAP)

Usage:
  iap.sh headers            all ticket headers (ID  STATUS  TYPE  TITLE  CREATED), oldest first
  iap.sh open               like headers, but without CLOSED tickets
  iap.sh list STATUS...     headers filtered by status, e.g. list DRAFT READY
  iap.sh next               highest-priority READY ticket (BUG > IMPROVEMENT > STORY, then oldest)
  iap.sh counts             ticket count per status
  iap.sh find PATTERN       ticket files whose name contains PATTERN
  iap.sh inferred           requirement/architecture files marked "origin: inferred"
  iap.sh preconditions      process commands whose preconditions are currently met
  iap.sh help

The spec root defaults to ./spec; override it with IAP_SPEC=/path/to/spec.
EOF
}

die() { echo "iap.sh: $*" >&2; exit 1; }

require_spec() {
  [ -d "$SPEC" ] || die "no '$SPEC' folder here — not bootstrapped yet (run /bootstrap)"
}

ticket_files() {
  { find "$SPEC/tickets" -type f -name '*.md' 2>/dev/null || true; } | sort
}

headers() {
  ticket_files | while IFS= read -r f; do
    awk -v file="$f" '
      NR==1          { title=$0; sub(/^#[ \t]*/, "", title) }
      /^STATUS:/     { status=$2 }
      /^TYPE:/       { type=$2 }
      /^CREATED-ON:/ { created=$2; sub(/T.*/, "", created) }
      END {
        printf "%s\t%s\t%s\t%s\t%s\n", \
          (created=="" ? "-" : created), (status=="" ? "-" : status), \
          (type=="" ? "-" : type), file, title
      }
    ' "$f"
  done | sort
}

# render — pretty-print `headers` (TSV: CREATED STATUS TYPE FILE TITLE) as the
# compact, space-aligned ticket list: ID  STATUS  TYPE  TITLE  CREATED.
render() {
  awk -F'\t' '
    function pad(s, w,   n) {
      n = w - length(s)
      return s (n > 0 ? sprintf("%*s", n, "") : "")
    }
    {
      i++
      ids[i] = $4
      sub(/^.*\//, "", ids[i]); sub(/\.md$/, "", ids[i]); sub(/-.*/, "", ids[i])
      created[i] = $1; sub(/^[0-9]+-/, "", created[i])
      status[i] = $2; type[i] = $3; title[i] = $5
      if (length($5) > tw) tw = length($5)
    }
    END {
      if (i == 0) exit
      printf "%s  %s  %s  %s  %s\n", \
        pad("ID", 4), pad("STATUS", 11), pad("TYPE", 11), pad("TITLE", tw), "CREATED"
      for (k = 1; k <= i; k++)
        printf "%s  %s  %s  %s  %s\n", \
          pad(ids[k], 4), pad(status[k], 11), pad(type[k], 11), pad(title[k], tw), created[k]
    }
  '
}

cmd_headers() { headers | render; }

cmd_open() { headers | awk -F'\t' '$2 != "CLOSED"' | render; }

cmd_list() {
  [ "$#" -gt 0 ] || die "usage: iap.sh list STATUS [STATUS...]"
  local want=" $* "
  headers | awk -F'\t' -v want="$want" 'index(want, " " $2 " ") > 0' | render
}

cmd_next() {
  headers | awk -F'\t' '
    $2 == "READY" {
      p = ($3 == "BUG") ? 1 : ($3 == "IMPROVEMENT") ? 2 : ($3 == "STORY") ? 3 : 4
      key = p "\t" $1 "\t" $4
      if (best == "" || key < best) { best = key; line = $0 }
    }
    END { if (best != "") print line }
  '
}

cmd_counts() {
  [ -d "$SPEC/tickets" ] || return 0
  { grep -rh '^STATUS:' "$SPEC/tickets" 2>/dev/null || true; } \
    | awk '{ c[$2]++ } END { for (s in c) print s, c[s] }' | sort
}

cmd_find() {
  [ "$#" -gt 0 ] || die "usage: iap.sh find PATTERN"
  { find "$SPEC/tickets" -type f -name "*$1*" 2>/dev/null || true; } | sort
}

cmd_inferred() {
  grep -rl 'origin: inferred' "$SPEC/requirements" "$SPEC/architecture" 2>/dev/null || true
}

cmd_preconditions() {
  if [ -s "$SPEC/input.md" ]; then echo "/facilitate — input.md is non-empty"; fi
  if grep -rq '^STATUS: READY'     "$SPEC/tickets" 2>/dev/null; then echo "/implement — READY ticket exists"; fi
  if grep -rq '^STATUS: IN_REVIEW' "$SPEC/tickets" 2>/dev/null; then echo "/review — IN_REVIEW ticket exists"; fi
  if grep -rq '^STATUS: DONE'      "$SPEC/tickets" 2>/dev/null; then echo "/accept — DONE ticket exists"; fi
  echo "/bootstrap, /plan, /refine, /tickets — always available"
  local manifests
  manifests="$(find . -maxdepth 4 -name node_modules -prune -o \
      \( -name pom.xml -o -name 'build.gradle*' -o -name package.json \
         -o -name go.mod -o -name Cargo.toml \) -print 2>/dev/null | wc -l)"
  if [ "$manifests" -gt 0 ]; then
    echo "/excavate, /survey — source code present"
  fi
}

main() {
  local cmd="${1:-help}"
  shift || true
  case "$cmd" in
    help|-h|--help) usage; return 0 ;;
  esac
  require_spec
  case "$cmd" in
    headers)       cmd_headers ;;
    open)          cmd_open ;;
    list)          cmd_list "$@" ;;
    next)          cmd_next ;;
    counts)        cmd_counts ;;
    find)          cmd_find "$@" ;;
    inferred)      cmd_inferred ;;
    preconditions) cmd_preconditions ;;
    *)             die "unknown command '$cmd' (try: iap.sh help)" ;;
  esac
}

main "$@"
