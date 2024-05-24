FROM node:20.12.2-slim as ci

COPY files/enketo/generate-secrets.sh ./
