# The web app, built with Flutter and served by nginx, which also proxies /api/ to the backend and /pipeline/ to the
# pipeline: the page and both APIs share one origin, so the browser needs no CORS and the build holds no address.
#
#   docker build -t radiologists-chatbot/web .
#   docker run --rm -p 8080:80 \
#       -e BACKEND_UPSTREAM=http://<backend>:4105 -e PIPELINE_UPSTREAM=http://<pipeline>:8000 \
#       radiologists-chatbot/web
#
# FLUTTER_BUILD_ARGS is passed to `flutter build web`, e.g. --build-arg FLUTTER_BUILD_ARGS="--dart-define=..."

# ─── Build ──────────────────────────────────────────────────────────────────
FROM debian:trixie-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git make unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# The SDK the project is developed with. No published Flutter image carries it, so it comes from its git tag.
ARG FLUTTER_VERSION=3.47.4
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:$PATH"
RUN flutter config --no-analytics --no-cli-animations \
    && flutter precache --web

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
ARG FLUTTER_BUILD_ARGS=""
# web/ is git-ignored: bootstrap-web generates it, as for a fresh clone.
RUN make bootstrap-web build-web ARGS="$FLUTTER_BUILD_ARGS"

# ─── Serve ──────────────────────────────────────────────────────────────────
FROM nginx:1.29.3-alpine

# The image renders /etc/nginx/templates/*.template into conf.d/ at start-up, substituting these from the environment.
ENV BACKEND_UPSTREAM=http://backend:4105 \
    PIPELINE_UPSTREAM=http://pipeline:8000 \
    NGINX_RESOLVER=127.0.0.11

COPY docker/nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
