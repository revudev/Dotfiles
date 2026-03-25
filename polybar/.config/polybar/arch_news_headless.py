#!/usr/bin/env -S python3 -B
import argparse
import json
import subprocess
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import TypedDict


class NewsState(TypedDict):
  read_titles: list[str]
  notified_titles: list[str]


FEED_URL   = "https://archlinux.org/feeds/news/"
STATE_FILE = Path("~/.cache/arch_news_state.json").expanduser()
TIMEOUT    = 6
MAX_ITEMS  = 10
MAX_STORED = 50
ICON_NEW   = "\U000F069A"
ICON_READ  = "\U000F08C7"
COLOR_WARN = "#e06c75"
COLOR_OK   = "#61afef"


def load_state() -> NewsState:
  try:
    with STATE_FILE.open() as f:
      data = json.load(f)
    if isinstance(data, dict):
      if "read_titles" in data:
        return NewsState(
          read_titles=list(data.get("read_titles", [])),
          notified_titles=list(data.get("notified_titles", [])),
        )
      if "title" in data and "is_read" in data:
        read = [data["title"]] if data.get("is_read") and data["title"] else []
        return NewsState(read_titles=read, notified_titles=read[:])
  except (FileNotFoundError, json.JSONDecodeError, KeyError):
    pass
  return NewsState(read_titles=[], notified_titles=[])


def save_state(state: NewsState) -> None:
  STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
  state["read_titles"] = state["read_titles"][-MAX_STORED:]
  state["notified_titles"] = state["notified_titles"][-MAX_STORED:]
  with STATE_FILE.open("w") as f:
    json.dump(state, f)


def fetch_items() -> list[tuple[str, str]]:
  try:
    req = urllib.request.Request(
      FEED_URL,
      headers={"User-Agent": "polybar-arch-news/1.0"},
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
      raw = resp.read()
  except Exception:
    return []

  try:
    root = ET.fromstring(raw)
    result = []
    for item in root.findall(".//item")[:MAX_ITEMS]:
      title_el = item.find("title")
      link_el  = item.find("link")
      title = (title_el.text or "").strip() if title_el is not None else ""
      link  = (link_el.text  or "").strip() if link_el  is not None else ""
      if title:
        result.append((title, link))
    return result
  except ET.ParseError:
    return []


def polybar_label(icon: str, color: str, count: int = 0) -> str:
  suffix = f" {count}" if count > 1 else ""
  return f"%{{T2}}%{{F{color}}}{icon}%{{F-}}%{{T-}}{suffix}"


def notify(title: str) -> None:
  subprocess.Popen(
    ["dunstify", "-u", "normal", "-i", "system-software-update", "Arch News", title],
    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
  )


def cmd_fetch() -> None:
  state = load_state()
  items = fetch_items()

  if not items:
    print(polybar_label(ICON_READ, COLOR_OK))
    return

  read_set = set(state["read_titles"])

  if items[0][0] in read_set:
    new_reads = [t for t, _ in items if t not in read_set]
    if new_reads:
      state["read_titles"].extend(new_reads)
      save_state(state)
    print(polybar_label(ICON_READ, COLOR_OK))
    return

  notified_set = set(state["notified_titles"])
  unread       = [(t, l) for t, l in items if t not in read_set]

  for title, _ in unread:
    if title not in notified_set:
      notify(title)
      state["notified_titles"].append(title)

  save_state(state)

  count = len(unread)
  print(polybar_label(ICON_NEW, COLOR_WARN, count))


def cmd_open() -> None:
  state    = load_state()
  items    = fetch_items()
  read_set = set(state["read_titles"])
  unread   = [(t, l) for t, l in items if t not in read_set]

  if unread:
    title, link = unread[0]
    if link:
      subprocess.Popen(["xdg-open", link], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    state["read_titles"].append(title)
    save_state(state)


def cmd_mark_read() -> None:
  state    = load_state()
  items    = fetch_items()
  read_set = set(state["read_titles"])

  for title, _ in items:
    if title not in read_set:
      state["read_titles"].append(title)

  save_state(state)


def main() -> None:
  parser = argparse.ArgumentParser(description="Arch news Polybar module")
  parser.add_argument("--mark-read", action="store_true")
  parser.add_argument("--open", action="store_true")
  args = parser.parse_args()

  if args.open:
    cmd_open()
  elif args.mark_read:
    cmd_mark_read()
  else:
    cmd_fetch()


if __name__ == "__main__":
  main()
