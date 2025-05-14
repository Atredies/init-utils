import feedparser
import iso8601
from datetime import timezone


def local_iso_date_string_to_utc_iso_date_string(d):
    return iso8601.parse_date(d).astimezone(timezone.utc).isoformat()


def prepare_entry(entry, feed):
    date = None
    if "published" in entry:
        date = local_iso_date_string_to_utc_iso_date_string(
            entry["published"]
        )
    if "updated" in entry:
        date = local_iso_date_string_to_utc_iso_date_string(
            entry["updated"]
        )
    return {
        "title": entry["title"],
        "date": date,
        "link": entry["link"],
        "authors": entry["authors"] if "authors" in entry else [],
        "source": {
            "title": feed["title"],
            "link": feed["link"],
            "image": feed["image"] if "image" in feed else None,
        }
    }


class Newsfeed:
    def __init__(self, feed_urls, fetch_feed=lambda url: feedparser.parse(url, sanitize_html=False, resolve_relative_uris=False)):
        self.feed_urls = feed_urls
        self.fetch_feed = fetch_feed

    def list(self, limit=100):
        all_feeds = [self.fetch_feed(u) for u in self.feed_urls]
        flattened_entries = [
            prepare_entry(entry, res.feed) for res in all_feeds for entry in res.entries
        ]
        sorted_entries = sorted(flattened_entries, key=lambda x : x["date"], reverse=True)

        return sorted_entries[0:limit]

