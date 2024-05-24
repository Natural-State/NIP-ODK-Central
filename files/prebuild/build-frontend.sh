#!/bin/bash -eu
cd client
npm clean-install --no-audit --fund=false --update-notifier=false
VUE_APP_OIDC_ENABLED="false" vue-cli-service build
