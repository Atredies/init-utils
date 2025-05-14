# Development

All services are built using Python3 and Flask. You should set up a virtualenv and install the dependencies for each service from `requirements.txt` if you intend to modify the application services.

## Running tests

You can run the tests of all apps by using `make test`

# Configuration

All the apps take environment variables to configure them and expose the URL `/ping` which will just return a 200 response that you can use with e.g. a load balancer to check if the app is running.

### Front-end app

    cd front-end && NEWSFEED_SERVICE_TOKEN="T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX" python -m flask run --port 8080

*Environment variables*:

* `STATIC_URL`: The URL on which to find the static assets (defaults to using local assets)
* `QUOTE_SERVICE_URL`: The URL on which to find the quote service (defaults to `http://localhost:8082`)
* `NEWSFEED_SERVICE_URL`: The URL on which to find the newsfeed service (defaults to `http://localhost:8081`)
* `NEWSFEED_SERVICE_TOKEN`: The authentication token that allows the app to talk to the newsfeed service. This should be treated as an application secret. The value should be: `T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX`

### Quote service

    cd quotes && python -m flask run --port 8082

### Newsfeed service

    cd newsfeed && python -m flask run --port 8081