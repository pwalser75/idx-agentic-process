#!/usr/bin/env bash
#
# iap.sh — fast, read-only helper for the idx Agentic Process (IAP).
#
# IAP keeps its state as Markdown under spec/. Every ticket is a file
# spec/tickets/{id}-{type}-{name}.md with YAML front matter:
#
#   ---
#   id: 0007
#   created: 2026-10-07T12:00:00Z
#   type: STORY
#   status: DRAFT
#   acceptance-type: AUTOMATIC
#   blocked-by: 0005, 0006
#   ---
#   # Title
#
# This helper gives an agent a single-pass view of that state, so it can run one
# command instead of opening every ticket or requirement file. It never writes.
#
# Usage:
#   iap.sh headers            all ticket headers: ID  STATUS  TYPE  TITLE  CREATED, oldest first
#   iap.sh open               like headers, but without CLOSED tickets
#   iap.sh list STATUS...     headers filtered by status, e.g. list DRAFT READY
#   iap.sh next               highest-priority READY, unblocked ticket (file path)
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
  iap.sh next               highest-priority READY, unblocked ticket (prints its file path)
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

# Emit one TSV row per ticket:
#   ID  STATUS  TYPE  TITLE  CREATED  BLOCKED-BY  FILE
ticket_tsv() {
  local f="$1" base fid
  base="${f##*/}"; base="${base%.md}"; fid="${base%%-*}"
  awk -v file="$f" -v fid="$fid" '
    NR == 1 && $0 == "---" { fm = 1; next }
    fm == 1 && $0 == "---" { fm = 0; next }
    fm == 1 {
      c = index($0, ":")
      if (c > 1) {
        k = substr($0, 1, c - 1); v = substr($0, c + 1)
        sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v)
        if      (k == "id")       id = v
        else if (k == "created")  created = v
        else if (k == "type")     type = v
        else if (k == "status")   status = v
        else if (k == "blocked-by") blocked = v
      }
      next
    }
    !title && $0 ~ /^#[ \t]+/ { title = $0; sub(/^#[ \t]+/, "", title) }
    END {
      if (id == "") id = fid
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
        id, (status == "" ? "-" : status), (type == "" ? "-" : type), \
        title, created, blocked, file
    }
  ' "$f"
}

all() {
  ticket_files | while IFS= read -r f; do ticket_tsv "$f"; done \
    | sort -t"$(printf '\t')" -k5,5 -k1,1
}

# Pretty-print TSV (ID STATUS TYPE TITLE CREATED BLOCKED FILE) as the compact
# space-aligned ticket list: ID  STATUS  TYPE  TITLE  CREATED.
render() {
  awk -F'\t' '
    function pad(s, w,   n) {
      n = w - length(s)
      return s (n > 0 ? sprintf("%*s", n, "") : "")
    }
    {
      i++
      id[i] = $1; status[i] = $2; type[i] = $3; title[i] = $4; created[i] = $5
      if (length($3) > tw) tw = length($3)
      if (length($4) > tw) tw = length($4)
    }
    END {
      if (i == 0) exit
      printf "%s  %s  %s  %s  %s\n", \
        pad("ID", 4), pad("STATUS", 11), pad("TYPE", 11), pad("TITLE", tw), "CREATED"
      for (k = 1; k <= i; k++)
        printf "%s  %s  %s  %s  %s\n", \
          pad(id[k], 4), pad(status[k], 11), pad(type[k], 11), \
          pad(title[k], tw), created[k]
    }
  '
}

cmd_headers() { all | render; }

cmd_open() { all | awk -F'\t' '$2 != "CLOSED"' | render; }

cmd_list() {
  [ "$#" -gt 0 ] || die "usage: iap.sh list STATUS [STATUS...]"
  local want=" $* "
  all | awk -F'\t' -v want="$want" 'index(want, " " $2 " ") > 0' | render
}

# Print the file path of the best READY, unblocked ticket: priority
# BUG > IMPROVEMENT > STORY, then oldest created, then lowest id.
cmd_next() {
  local tsv="$1" closed
  closed="$(printf '%s\n' "$tsv" | awk -F'\t' '$2 == "CLOSED" { printf "%s ", $1 }')"
  printf '%s\n' "$tsv" | awk -F'\t' -v closed=" $closed " '
    function blocked(b,   n, i, a) {
      gsub(/[][",]/, " ", b); gsub(/[][]/, " ", b)
      n = split(b, a, " ")
      for (i = 1; i <= n; i++) {
        if (a[i] == "" || a[i] == "-") continue
        if (index(closed, " " a[i] " ") == 0) return 1
      }
      return 0
    }
    $2 == "READY" {
      if (blocked($6)) next
      p = ($3 == "BUG") ? 1 : ($3 == "IMPROVEMENT") ? 2 : ($3 == "STORY") ? 3 : 4
      key = p "\t" $5 "\t" $1
      if (best == "" || key < best) { best = key; sel = $7 }
    }
    END { if (sel != "") print sel }
  '
}

cmd_counts() {
  [ -d "$SPEC/tickets" ] || return 0
  all | awk -F'\t' '{ c[$2]++ } END { for (s in c) print s, c[s] }' | sort
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
  if all | grep -q $'\tREADY\t'; then echo "/implement — READY ticket exists"; fi
  if all | grep -q $'\tIN_REVIEW\t'; then echo "/review — IN_REVIEW ticket exists"; fi
  local done_auto done_human
  done_auto="$(all  | awk -F'\t' '$2 == "DONE" { print $7 }' | xargs -r grep -l 'acceptance-type:[[:space:]]*AUTOMATIC' 2>/dev/null | wc -l)"
  done_human="$(all | awk -F'\t' '$2 == "DONE" { print $7 }' | xargs -r grep -l 'acceptance-type:[[:space:]]*HUMAN' 2>/dev/null | wc -l)"
  [ "$done_auto"  -gt 0 ] && echo "/accept — AUTOMATIC DONE ticket exists (reviewer)"
  [ "$done_human" -gt 0 ] && echo "/accept — HUMAN DONE ticket awaits acceptance"
  echo "/guide, /reconcile, /bootstrap, /plan, /refine, /tickets — always available"
  local manifests
  manifests="$(find . -maxdepth 4 -name node_modules -prune -o \
      \( -name pom.xml -o -name 'build.gradle*' -o -name package.json \
         -o -name go.mod -o -name Cargo.toml -o -name pyproject.toml \) -print 2>/dev/null | wc -l)"
  [ "$manifests" -gt 0 ] && echo "/excavate, /survey — source code present"
  return 0
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
    next)          cmd_next "$(all)" ;;
    counts)        cmd_counts ;;
    find)          cmd_find "$@" ;;
    inferred)      cmd_inferred ;;
    preconditions) cmd_preconditions ;;
    *)             die "unknown command '$cmd' (try: iap.sh help)" ;;
  esac
}

main "$@"
