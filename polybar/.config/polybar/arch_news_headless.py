#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import TypedDict


class NewsState(TypedDict):
  title: str
  is_read: bool

FEED_URL    = "https://archlinux.org/feeds/news/"
STATE_FILE  = Path("~/.cache/arch_news_state.json").expanduser()
TITLE_MAX   = 35
TIMEOUT     = 6
ICON_NEW    = "󰚺"
ICON_READ   = "󰣇"
COLOR_WARN  = "#e5c07b"
COLOR_OK    = "#707880"



def load_state() -> NewsState:
  try:
    with STATE_FILE.open() as f:
      data = json.load(f)
      if isinstance(data, dict) and "title" in data and "is_read" in data:
        return NewsState(title=str(data["title"]), is_read=bool(data["is_read"]))
  except (FileNotFoundError, json.JSONDecodeError, KeyError):
    pass
  return NewsState(title="", is_read=True)


def save_state(state: NewsState) -> None:
  STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
  with STATE_FILE.open("w") as f:
    json.dump(state, f)

def fetch_latest() -> tuple[str, str] | None:
  try:
    req = urllib.request.Request(
      FEED_URL,
      headers={"User-Agent": "polybar-arch-news/1.0"},
    )
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
      raw = resp.read()
  except Exception:
    return None

  try:
    root = ET.fromstring(raw)
    ns = {"atom": "http://www.w3.org/2005/Atom"}
    items = root.findall(".//item")
    if not items:
      return None
    first = items[0]
    title_el = first.find("title")
    link_el  = first.find("link")
    title = (title_el.text or "").strip() if title_el is not None else ""
    link  = (link_el.text  or "").strip() if link_el  is not None else ""
    return title, link
  except ET.ParseError:
      return None



def polybar_label(icon: str, text: str, color: str) -> str:
  return f"%{{F{color}}}{icon} {text}%{{F-}}"


def truncate(s: str, n: int) -> str:
  return s if len(s) <= n else s[: n - 1] + "…"



def cmd_fetch() -> None:
  state  = load_state()
  latest = fetch_latest()

  if latest is None:
    print(polybar_label(ICON_READ, "Arch", COLOR_OK))
    return

  latest_title, _ = latest

  if latest_title != state["title"]:
    state["title"]   = latest_title
    state["is_read"] = False
    save_state(state)

  if not state["is_read"]:
    short = truncate(latest_title, TITLE_MAX)
    print(polybar_label(ICON_NEW, short, COLOR_WARN))
  else:
    print(polybar_label(ICON_READ, "Arch", COLOR_OK))


def cmd_mark_read() -> None:
  state = load_state()
  latest = fetch_latest()

  if latest is not None:
    state["title"] = latest[0]

  state["is_read"] = True
  save_state(state)

def main() -> None:
  parser = argparse.ArgumentParser(description="Arch news Polybar module")
  parser.add_argument(
    "--mark-read",
    action="store_true",
    help="Mark the current news item as read and exit",
  )
  args = parser.parse_args()

  if args.mark_read:
    cmd_mark_read()
  else:
    cmd_fetch()


if __name__ == "__main__":
  main()
