
# Clone the repository
# https://github.com/Natural-State/NIP-ODK-Central.git

cd /Users/rosstyzackpitman/Documents/NaturalState/CTEC/Apps/NIP/NIP-ODK-Central

git pull
git submodule update -i

docker build --platform linux/amd64 . -f service.dockerfile -t naturalstate/odk_service:1.0.1.0
docker build --platform linux/amd64 . -f nginx.dockerfile -t naturalstate/odk_nginx:1.0.1.0
docker build --platform linux/amd64 . -f enketo.dockerfile -t naturalstate/odk_enketo:1.0.1.0
docker build --platform linux/amd64 . -f secrets.dockerfile -t naturalstate/odk_secrets:1.0.1.0

# Push to dockerhub
docker login
docker push naturalstate/odk_service:1.0.1.0
docker push naturalstate/odk_nginx:1.0.1.0
docker push naturalstate/odk_enketo:1.0.1.0
docker push naturalstate/odk_secrets:1.0.1.0