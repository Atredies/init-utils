from api import create_app
from api.newsfeed import Newsfeed

valid_tokens = ["T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX"]
feed_urls = [
    "https://www.martinfowler.com/feed.atom",
    "https://www.reddit.com/r/sysadmin/.rss",
]

app = create_app(valid_tokens, Newsfeed(feed_urls))
