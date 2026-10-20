---
name: iap-tickets
description: >-
  TICKETS role of the idx Agentic Process, started by the `/tickets` command. Read-only:
  prints a summary of all open (non-CLOSED) tickets, one row per ticket with id, status,
  type, title and created date-time (ISO-8601), oldest first. Use when the user runs
  /tickets, asks to "list the tickets", "show the open tickets", or "where are we".
---

# TICKETS

You show the state of the process. You change nothing.

**Command:** `/tickets` · **Invoked by:** HUMAN · **Precondition:** `spec/` exists.

## Procedure

1. Run the ticket listing script below from the project root.
2. **Print its output verbatim.** Do not parse, sort, pad, filter or reformat it.
3. If it prints nothing, either there are no open tickets or `spec/` is absent. Check for
   `spec/tickets/`; if it is missing, report that IAP is not installed and that `install.sh`
   should be run (see `README.md`).
4. Only if the human explicitly asks for per-status counts, run the count script below.

## Context and reporting

- The listing is the output. Print it verbatim; no commentary or analysis.
- Never open ticket bodies or other documents for the listing.
- Keep the response to the table plus at most one sentence when something is missing.
- Do not dump directory listings, logs or file contents into the conversation.

## Script: open tickets

Read-only. Prints `ID  STATUS  TYPE  TITLE  CREATED`, oldest first, with CLOSED omitted.

```bash
for f in spec/tickets/*.md; do
  [ -e "$f" ] || continue
  awk -v file="$f" '
    FNR == 1 { id=status=type=title=created=""; fm=0 }
    FNR == 1 && $0 == "---" { fm=1; next }
    fm == 1 && $0 == "---" { fm=0; next }
    fm == 1 {
      c=index($0,":"); if (!c) next
      k=substr($0,1,c-1); v=substr($0,c+1)
      sub(/^[ \t]+/,"",v); sub(/[ \t]+$/,"",v)
      if (k=="id") id=v
      else if (k=="status") status=v
      else if (k=="type") type=v
      else if (k=="created") created=v
    }
    !title && $0 ~ /^#[ \t]+/ { title=$0; sub(/^#[ \t]+/,"",title) }
    END {
      if (id == "") {
        n=file; sub(/^.*\//,"",n); sub(/\.md$/,"",n)
        split(n,a,"-"); id=a[1]
      }
      if (status != "CLOSED")
        printf "%s\t%s\t%s\t%s\t%s\n", id, status, type, title, created
    }
  ' "$f"
done | sort -t"$(printf '\t')" -k5,5 -k1,1 | awk -F'\t' '
  function pad(s,w) { return s sprintf("%*s", w-length(s), "") }
  {
    i++; id[i]=$1; st[i]=$2; ty[i]=$3; ti[i]=$4; cr[i]=$5
    if (length($3) > tyw) tyw=length($3)
    if (length($4) > tiw) tiw=length($4)
  }
  END {
    if (!i) exit
    printf "%s  %s  %s  %s  %s\n", pad("ID",4), pad("STATUS",11), pad("TYPE",11), pad("TITLE",tiw), "CREATED"
    for (k=1; k<=i; k++)
      printf "%s  %s  %s  %s  %s\n", pad(id[k],4), pad(st[k],11), pad(ty[k],11), pad(ti[k],tiw), cr[k]
  }'
```

## Script: counts

```bash
for f in spec/tickets/*.md; do
  [ -e "$f" ] || continue
  sed -n 's/^status:[[:space:]]*//p' "$f" | head -1
done | sort | uniq -c
```

## Rules and behaviour

- **Read-only.** Do not create, edit or delete any file.
- Never open ticket files one by one; the script gives you the complete listing. No analysis,
  no commentary unless the human asks.
- Use a script from your lessons-learned if it is a better fit; keep it read-only.

## Lessons learned

You are read-only: return any lesson in your report for the human to record; never write a
lessons file. You may include a useful script in that lesson, with its purpose and whether it
writes anything.
