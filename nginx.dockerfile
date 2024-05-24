FROM node:14-slim as intermediate

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./ ./

COPY files/prebuild/write-version.sh /app/files/prebuild/write-version.sh
COPY files/prebuild/build-frontend.sh /app/files/prebuild/build-frontend.sh

# Make files executable
RUN chmod +x files/prebuild/write-version.sh \
    && chmod +x files/prebuild/build-frontend.sh \
    && ./files/prebuild/write-version.sh

ARG OIDC_ENABLED
RUN OIDC_ENABLED="$OIDC_ENABLED" ./files/prebuild/build-frontend.sh

FROM jonasal/nginx-certbot:5.0.1

EXPOSE 80
EXPOSE 443

RUN apt-get update && apt-get install -y netcat-openbsd

# Create necessary directories
RUN mkdir -p /usr/share/odk/nginx/ \
    && mkdir -p /usr/share/nginx/html \
    && mkdir -p /etc/customssl/live/local \
    && mkdir -p /scripts

COPY files/nginx/setup-odk.sh /scripts/
COPY files/local/customssl/*.pem /etc/customssl/live/local/
COPY files/nginx/*.conf* /usr/share/odk/nginx/

COPY --from=intermediate /app/client/dist/ /usr/share/nginx/html
COPY --from=intermediate /app/tmp/version.txt /usr/share/nginx/html
