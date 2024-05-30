# Deploy ODK Central via Docker

export ENV_PATH="/Users/rosstyzackpitman/Documents/NaturalState/CTEC/Apps/NIP/NIP-ODK-Central/.env_dev"
export $(grep -v '^#' $ENV_PATH | xargs)
echo $DOCKERHUB_USER
echo $ENV
echo $ENV_PATH
echo $ENKETO_API_KEY
echo $DB_HOST

cd /Users/rosstyzackpitman/Documents/NaturalState/CTEC/Apps/NIP/NIP-ODK-Central

docker compose up
