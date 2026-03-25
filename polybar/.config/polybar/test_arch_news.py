#!/usr/bin/env -S python3 -B
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent))
import arch_news_headless as m


class TestIcons(unittest.TestCase):
  def test_icon_new_codepoint(self):
    self.assertEqual(ord(m.ICON_NEW), 0xF069A)

  def test_icon_read_codepoint(self):
    self.assertEqual(ord(m.ICON_READ), 0xF08C7)

  def test_icon_new_utf8_bytes(self):
    self.assertEqual(m.ICON_NEW.encode(), b"\xf3\xb0\x9a\x9a")

  def test_icon_read_utf8_bytes(self):
    self.assertEqual(m.ICON_READ.encode(), b"\xf3\xb0\xa3\x87")


class TestPolybarLabel(unittest.TestCase):
  def test_read_state(self):
    out = m.polybar_label(m.ICON_READ, m.COLOR_OK)
    self.assertIn("%{T2}", out)
    self.assertIn("%{T-}", out)
    self.assertIn(m.COLOR_OK, out)
    self.assertNotIn(" ", out.split(m.ICON_READ)[-1].split("%")[0])

  def test_new_single_no_count(self):
    out = m.polybar_label(m.ICON_NEW, m.COLOR_WARN, count=1)
    self.assertNotIn(" 1", out)

  def test_new_multi_shows_count(self):
    out = m.polybar_label(m.ICON_NEW, m.COLOR_WARN, count=3)
    self.assertIn(" 3", out)


class TestLoadState(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.NamedTemporaryFile(suffix=".json", delete=False)
    self.orig = m.STATE_FILE
    m.STATE_FILE = Path(self.tmp.name)

  def tearDown(self):
    m.STATE_FILE = self.orig
    Path(self.tmp.name).unlink(missing_ok=True)

  def test_missing_file_returns_empty(self):
    m.STATE_FILE = Path("/tmp/does_not_exist_arch_news.json")
    state = m.load_state()
    self.assertEqual(state["read_titles"], [])
    self.assertEqual(state["notified_titles"], [])

  def test_migration_from_old_format_read(self):
    m.STATE_FILE.write_text(json.dumps({
      "title": "Some old title",
      "link": "https://archlinux.org",
      "is_read": True,
    }))
    state = m.load_state()
    self.assertIn("Some old title", state["read_titles"])

  def test_migration_from_old_format_unread(self):
    m.STATE_FILE.write_text(json.dumps({
      "title": "Unread title",
      "link": "https://archlinux.org",
      "is_read": False,
    }))
    state = m.load_state()
    self.assertEqual(state["read_titles"], [])

  def test_new_format_roundtrip(self):
    original = {"read_titles": ["a", "b"], "notified_titles": ["a"]}
    m.STATE_FILE.write_text(json.dumps(original))
    state = m.load_state()
    self.assertEqual(state["read_titles"], ["a", "b"])
    self.assertEqual(state["notified_titles"], ["a"])


class TestHeuristic(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.NamedTemporaryFile(suffix=".json", delete=False)
    self.orig = m.STATE_FILE
    m.STATE_FILE = Path(self.tmp.name)

  def tearDown(self):
    m.STATE_FILE = self.orig
    Path(self.tmp.name).unlink(missing_ok=True)

  def test_newest_read_marks_all_as_read(self):
    items = [("newest", "url1"), ("older", "url2"), ("oldest", "url3")]
    m.STATE_FILE.write_text(json.dumps({
      "read_titles": ["newest"],
      "notified_titles": ["newest"],
    }))

    output = []
    with patch.object(m, "fetch_items", return_value=items), \
         patch("builtins.print", side_effect=output.append):
      m.cmd_fetch()

    state = m.load_state()
    self.assertIn("older", state["read_titles"])
    self.assertIn("oldest", state["read_titles"])
    self.assertIn(m.COLOR_OK, output[0])

  def test_unread_item_shows_red(self):
    items = [("new article", "url1"), ("read article", "url2")]
    m.STATE_FILE.write_text(json.dumps({
      "read_titles": ["read article"],
      "notified_titles": ["read article"],
    }))

    output = []
    with patch.object(m, "fetch_items", return_value=items), \
         patch("builtins.print", side_effect=output.append), \
         patch.object(m, "notify"):
      m.cmd_fetch()

    self.assertIn(m.COLOR_WARN, output[0])

  def test_count_shown_when_multiple_unread(self):
    items = [("a", "u1"), ("b", "u2"), ("c", "u3")]
    m.STATE_FILE.write_text(json.dumps({
      "read_titles": [],
      "notified_titles": [],
    }))

    output = []
    with patch.object(m, "fetch_items", return_value=items), \
         patch("builtins.print", side_effect=output.append), \
         patch.object(m, "notify"):
      m.cmd_fetch()

    self.assertIn(" 3", output[0])


if __name__ == "__main__":
  result = unittest.main(verbosity=2, exit=False)
  sys.exit(0 if result.result.wasSuccessful() else 1)
