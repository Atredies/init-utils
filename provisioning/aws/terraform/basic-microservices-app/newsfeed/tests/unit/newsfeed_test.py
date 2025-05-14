
from dataclasses import dataclass
from api.newsfeed import Newsfeed
from collections import namedtuple
import pytest

Response = namedtuple("Response", ["feed", "entries"])

def feed(title):
    return {
        "title": title,
        "link": "http://example.com"
    }

def rss_entry(title, published, updated=None):
    return {
        "title": title,
        "published": published,
        "updated": updated if updated else published,
        "link": "http://example.com/entry"
    }


def test_list_combines_and_sorts_feeds():
    def fetch_feed_stub(url):
        if url == "url1":
            return Response(feed("one"), [
                rss_entry("a", "2022-01-01T01:00:00Z"),
                rss_entry("b", "2022-01-01T03:00:00Z"),
            ])
        if url == "url2":
            return Response(feed("two"), [
                rss_entry("c", "2022-01-01T02:00:00Z"),
                rss_entry(
                    "d",
                    "2022-01-01T00:00:00Z",
                    "2022-01-01T04:00:00Z",
                ),
            ])

        raise "Invalid url"

    n = Newsfeed(["url1", "url2"], fetch_feed_stub)
    entries = n.list()

    assert len(entries) == 4
    assert entries[0]["title"] == "d"
    assert entries[1]["title"] == "b"
    assert entries[2]["title"] == "c"
    assert entries[3]["title"] == "a"


def test_list_normalises_dates_to_utc_iso_format():
    def fetch_feed_stub(url):
        return Response(feed("feed"), [
            rss_entry("a", "2021-12-26T11:21:00-05:00"),
            rss_entry("b", "2022-01-01T03:00:00Z"),
        ])

    n = Newsfeed(["url1"], fetch_feed_stub)
    entries = n.list()

    assert len(entries) == 2
    assert entries[0]["date"] == "2022-01-01T03:00:00+00:00"
    assert entries[1]["date"] == "2021-12-26T16:21:00+00:00"
