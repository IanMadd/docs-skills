#!/usr/bin/env python3
"""Move Hugo menu branch entries out of page front matter and into menu.toml.

A "branch page" is a page whose front matter menu identifier is used as the
`parent` of another menu entry, and that identifier isn't defined in menu.toml.
For each branch page this script:

1. Copies the page's menu table into menu.toml as a `[[<menu>]]` table,
   indented two spaces per nesting level and placed under its parent entry.
2. Turns the page into a leaf: its new parent is its old identifier, and its
   new identifier is `<old identifier>/<slug of the page title>`.

The script runs as a dry run by default and prints a report. Pass --apply to
write the changes.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import tomllib
from dataclasses import dataclass, field
from pathlib import Path

MENU_HEADER_RE = re.compile(r"^\s*\[menu\.([A-Za-z0-9_-]+)\]\s*$")
ANY_HEADER_RE = re.compile(r"^\s*\[")
MENU_TOML_HEADER_RE = re.compile(r"^(\s*)\[\[([A-Za-z0-9_-]+)\]\]\s*$")
KEY_LINE_RE = re.compile(r"^\s*([A-Za-z0-9_-]+)\s*=")


@dataclass
class PageMenu:
    path: Path
    menu: str
    entry: dict
    page_title: str | None
    # Line indexes (in the whole file) of the [menu.<name>] table, header inclusive.
    start: int
    end: int
    raw_lines: list[str]

    @property
    def identifier(self) -> str | None:
        return self.entry.get("identifier")

    @property
    def parent(self) -> str | None:
        return self.entry.get("parent")


@dataclass
class Plan:
    branches: list[dict] = field(default_factory=list)
    duplicates: list[dict] = field(default_factory=list)
    dangling_parents: list[dict] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


def slugify(text: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return slug or "overview"


def read_front_matter(path: Path) -> tuple[list[str], int, int] | None:
    """Return (lines, fm_start, fm_end) for TOML front matter delimited by +++."""
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    if not lines or lines[0].strip() != "+++":
        return None
    for i in range(1, len(lines)):
        if lines[i].strip() == "+++":
            return lines, 1, i
    return None


def collect_pages(content_dir: Path, plan: Plan, files: list[Path] | None = None) -> list[PageMenu]:
    pages: list[PageMenu] = []
    for path in files if files is not None else sorted(content_dir.rglob("*.md")):
        text = path.read_text(encoding="utf-8")
        if text.startswith("---"):
            if re.search(r"^menu:", text, re.M):
                plan.warnings.append(f"{path}: YAML front matter menus aren't supported; review manually.")
            continue
        fm = read_front_matter(path)
        if not fm:
            continue
        lines, fm_start, fm_end = fm
        try:
            data = tomllib.loads("".join(lines[fm_start:fm_end]))
        except tomllib.TOMLDecodeError as err:
            plan.warnings.append(f"{path}: invalid TOML front matter ({err}).")
            continue
        menus = data.get("menu")
        if menus is None:
            continue
        if not isinstance(menus, dict):
            plan.warnings.append(f"{path}: `menu` isn't a table; review manually.")
            continue
        for i in range(fm_start, fm_end):
            m = MENU_HEADER_RE.match(lines[i])
            if not m:
                continue
            name = m.group(1)
            end = i + 1
            while end < fm_end and not ANY_HEADER_RE.match(lines[end]):
                end += 1
            entry = menus.get(name)
            if not isinstance(entry, dict):
                continue
            if any(isinstance(v, dict) for v in entry.values()):
                plan.warnings.append(f"{path}: [menu.{name}] has nested tables; review manually.")
            pages.append(PageMenu(path, name, entry, data.get("title"), i, end, lines[i:end]))
    return pages


def menu_toml_entries(menu_file: Path) -> dict[str, dict]:
    data = tomllib.loads(menu_file.read_text(encoding="utf-8"))
    entries: dict[str, dict] = {}
    for menu_name, items in data.items():
        if not isinstance(items, list):
            continue
        for item in items:
            ident = item.get("identifier")
            if ident:
                entries[ident] = {"menu": menu_name, **item}
    return entries


def build_plan(menu_file: Path, content_dir: Path) -> tuple[Plan, list[PageMenu], dict]:
    plan = Plan()
    toml_entries = menu_toml_entries(menu_file)
    pages = collect_pages(content_dir, plan)

    page_by_id: dict[str, PageMenu] = {}
    for p in pages:
        if not p.identifier:
            continue
        if p.identifier in page_by_id:
            plan.warnings.append(
                f"Identifier {p.identifier!r} is defined in both {page_by_id[p.identifier].path} and {p.path}."
            )
            continue
        page_by_id[p.identifier] = p

    parents_used: set[str] = {p.parent for p in pages if p.parent}
    parents_used |= {e["parent"] for e in toml_entries.values() if e.get("parent")}

    all_ids = set(toml_entries) | set(page_by_id)
    taken_ids = set(all_ids)

    for parent in sorted(parents_used - all_ids):
        users = [str(p.path) for p in pages if p.parent == parent]
        users += [f"menu.toml:{i}" for i, e in toml_entries.items() if e.get("parent") == parent]
        plan.dangling_parents.append({"parent": parent, "used_by": users})

    def new_leaf_id(page: PageMenu) -> str:
        base = f"{page.identifier}/{slugify(page.page_title or page.entry.get('title', 'overview'))}"
        candidate, n = base, 2
        while candidate in taken_ids:
            candidate = f"{base}-{n}"
            n += 1
        taken_ids.add(candidate)
        return candidate

    for ident, page in sorted(page_by_id.items()):
        if ident in toml_entries:
            plan.duplicates.append(
                {
                    "file": str(page.path),
                    "menu": page.menu,
                    "identifier": ident,
                    "new_identifier": new_leaf_id(page),
                    "new_parent": ident,
                }
            )
        elif ident in parents_used:
            children = [str(p.path) for p in pages if p.parent == ident]
            children += [f"menu.toml:{i}" for i, e in toml_entries.items() if e.get("parent") == ident]
            plan.branches.append(
                {
                    "file": str(page.path),
                    "menu": page.menu,
                    "identifier": ident,
                    "parent": page.parent,
                    "children": children,
                    "new_identifier": new_leaf_id(page),
                    "new_parent": ident,
                }
            )

    return plan, pages, toml_entries


def depth_of(ident: str, parent_of: dict[str, str | None]) -> int:
    depth, seen, cur = 0, {ident}, parent_of.get(ident)
    while cur:
        if cur in seen:
            break
        seen.add(cur)
        depth += 1
        cur = parent_of.get(cur)
    return depth


def table_blocks(lines: list[str]) -> list[tuple[str, str | None, int, int]]:
    """Return (menu, identifier, header_index, last_key_index) for each [[menu]] table."""
    blocks = []
    i = 0
    while i < len(lines):
        m = MENU_TOML_HEADER_RE.match(lines[i])
        if not m:
            i += 1
            continue
        header, last, ident = i, i, None
        j = i + 1
        while j < len(lines) and KEY_LINE_RE.match(lines[j]):
            last = j
            km = re.match(r'^\s*identifier\s*=\s*"([^"]*)"', lines[j])
            if km:
                ident = km.group(1)
            j += 1
        blocks.append((m.group(2), ident, header, last))
        i = j
    return blocks


def insert_into_menu_toml(menu_file: Path, branches: list[dict], pages_by_id: dict, parent_of: dict) -> None:
    lines = menu_file.read_text(encoding="utf-8").splitlines(keepends=True)
    if lines and not lines[-1].endswith("\n"):
        lines[-1] += "\n"

    # Shallowest first so each parent table exists before its children are placed.
    ordered = sorted(
        branches,
        key=lambda b: (depth_of(b["identifier"], parent_of), pages_by_id[b["identifier"]].entry.get("weight", 0)),
    )
    for b in ordered:
        page = pages_by_id[b["identifier"]]
        indent = "  " * depth_of(b["identifier"], parent_of)
        body = [ln.strip() for ln in page.raw_lines[1:] if ln.strip()]
        table = [f"{indent}[[{page.menu}]]\n"] + [f"{indent}{ln}\n" for ln in body]

        blocks = table_blocks(lines)
        parent = page.parent
        if parent:
            parent_block = next((blk for blk in blocks if blk[1] == parent), None)
            if parent_block is None:
                raise SystemExit(f"Parent {parent!r} of {b['identifier']!r} isn't in menu.toml; can't place it.")
            idx = blocks.index(parent_block)
            last = parent_block[3]
            for blk in blocks[idx + 1 :]:
                if blk[1] and blk[1].startswith(parent + "/"):
                    last = blk[3]
                else:
                    break
            lines[last + 1 : last + 1] = ["\n"] + table
        else:
            same_menu = [blk for blk in blocks if blk[0] == page.menu]
            if same_menu:
                at = same_menu[0][2]
                lines[at:at] = table + ["\n"]
            else:
                lines += ["\n", "####\n", f"## {page.entry.get('title', page.menu)} ##\n", "####\n", "\n"] + table
    menu_file.write_text("".join(lines), encoding="utf-8")


def rewrite_page(page: PageMenu, new_identifier: str, new_parent: str) -> None:
    lines = page.path.read_text(encoding="utf-8").splitlines(keepends=True)
    seg = lines[page.start : page.end]
    ident_idx = parent_idx = None
    for k, ln in enumerate(seg):
        km = KEY_LINE_RE.match(ln)
        if not km:
            continue
        if km.group(1) == "identifier":
            ident_idx = k
        elif km.group(1) == "parent":
            parent_idx = k
    indent = re.match(r"^(\s*)", seg[ident_idx]).group(1)
    seg[ident_idx] = f'{indent}identifier = "{new_identifier}"\n'
    if parent_idx is not None:
        seg[parent_idx] = f'{indent}parent = "{new_parent}"\n'
    else:
        seg.insert(ident_idx + 1, f'{indent}parent = "{new_parent}"\n')
    lines[page.start : page.end] = seg
    page.path.write_text("".join(lines), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", type=Path, required=True, help="Hugo site root.")
    ap.add_argument("--menu-file", type=Path, help="Defaults to <repo>/config/_default/menu.toml.")
    ap.add_argument("--content-dir", type=Path, help="Defaults to <repo>/content.")
    ap.add_argument(
        "--only",
        action="append",
        default=[],
        help="Limit fixes to this identifier and its ancestors. Repeatable.",
    )
    ap.add_argument("--apply", action="store_true", help="Write changes. Without it, only report.")
    ap.add_argument("--json", action="store_true", help="Print the report as JSON.")
    args = ap.parse_args()

    repo = args.repo.resolve()
    menu_file = (args.menu_file or repo / "config/_default/menu.toml").resolve()
    content_dir = (args.content_dir or repo / "content").resolve()

    plan, pages, toml_entries = build_plan(menu_file, content_dir)
    pages_by_id = {p.identifier: p for p in pages if p.identifier}
    parent_of = {i: e.get("parent") for i, e in toml_entries.items()}
    parent_of.update({p.identifier: p.parent for p in pages if p.identifier})

    if args.only:
        keep: set[str] = set()
        for ident in args.only:
            cur = ident
            while cur and cur not in keep:
                keep.add(cur)
                cur = parent_of.get(cur)
        plan.branches = [b for b in plan.branches if b["identifier"] in keep]
        plan.duplicates = [d for d in plan.duplicates if d["identifier"] in keep]

    for b in plan.branches:
        b["indent"] = 2 * depth_of(b["identifier"], parent_of)

    if args.json:
        print(json.dumps(plan.__dict__, indent=2))
    else:
        print(f"Branch pages to move into menu.toml: {len(plan.branches)}")
        for b in plan.branches:
            print(f"  - {b['identifier']}  ({b['file']})")
            print(f"      menu.toml: [[{b['menu']}]] indented {b['indent']} spaces, parent {b['parent']!r}")
            print(f"      page:      identifier -> {b['new_identifier']!r}, parent -> {b['new_parent']!r}")
            print(f"      children:  {len(b['children'])}")
        print(f"Pages that duplicate a menu.toml identifier: {len(plan.duplicates)}")
        for d in plan.duplicates:
            print(f"  - {d['identifier']}  ({d['file']}) -> identifier {d['new_identifier']!r}, parent {d['new_parent']!r}")
        print(f"Parents with no matching identifier anywhere: {len(plan.dangling_parents)}")
        for d in plan.dangling_parents:
            print(f"  - {d['parent']} used by {', '.join(d['used_by'])}")
        for w in plan.warnings:
            print(f"WARNING: {w}")

    if args.apply:
        insert_into_menu_toml(menu_file, plan.branches, pages_by_id, parent_of)
        # Re-read each page before editing so line offsets stay accurate when
        # one file has more than one menu table.
        for item in plan.branches + plan.duplicates:
            target = Path(item["file"])
            fresh = next(
                p for p in collect_pages(content_dir, Plan(), [target]) if p.menu == item["menu"]
            )
            rewrite_page(fresh, item["new_identifier"], item["new_parent"])
        print("Applied changes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
