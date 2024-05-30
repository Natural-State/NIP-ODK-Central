# Deploy ODK Central from local machine to Azure Kubernetes Service (AKS)

export ENV_PATH="/Users/rosstyzackpitman/Documents/NaturalState/CTEC/Apps/NIP/NIP-ODK-Central/.env_dev"
export $(grep -v '^#' $ENV_PATH | xargs)


echo "ENV_PATH: $ENV_PATH"
echo "BACKEND_PORT: $BACKEND_PORT"
echo "FRONTEND_PORT: $FRONTEND_PORT"
echo "SYSADMIN_EMAIL: $SYSADMIN_EMAIL"
echo "DB_HOST: $DB_HOST"
echo "DB_USER: $DB_USER"
echo "DB_PASSWORD: $DB_PASSWORD"
echo "DB_NAME: $DB_NAME"
echo "DB_SSL: $DB_SSL"
echo "ENKETO_API_KEY: $ENKETO_API_KEY"
echo "BACKEND_APP_DOMAIN: $BACKEND_APP_DOMAIN"
echo "ENKETO_DOMAIN: $ENKETO_DOMAIN"
echo "FRONTEND_APP_DOMAIN: $FRONTEND_APP_DOMAIN"

cd /Users/rosstyzackpitman/Documents/NaturalState/CTEC/Apps/NIP/NIP-ODK-Central/.github/workflows

source ./deployment.sh

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
DB_HOST=$(./keyvault.sh host $POSTGRES_KEYVAULT)
DB_USER=$(./keyvault.sh username $POSTGRES_KEYVAULT)
DB_PASSWORD=$(./keyvault.sh password $POSTGRES_KEYVAULT)

source ./context.sh -g $KUBERNETES_RESOURCE_GROUP -n $KUBERNETES_CLUSTER_NAME

APP_NAME="odk-central"
helm_release="${APP_NAME}-release"
namespace="${APP_NAME}-namespace"
tls_secret_name="ingress-tls-odk-central"
postgres_secret_name="postgres-odk-central"
ENKETO_API_NAME="enketo"

source ./secrets.sh \
    --namespace $namespace \
    --tls-secret-name $tls_secret_name \
    --tls-crt $TLS_CRT \
    --tls-key $TLS_KEY \
    --postgres-secret $postgres_secret_name \
    --postgres-password $PGPASSWORD \
    --enketo-secret $ENKETO_API_NAME \
    --enketo-api-key $ENKETO_API_KEY

helm dependency update "../../helm/odk-central"

# Deploy odk-central with override
helm upgrade \
    -n odk-central-namespace \
    "$HELM_RELEASE" \
    --install \
    "../../helm/odk-central" \
    -f "../../helm/odk-central/values.yaml" \
    --set service.port="${BACKEND_PORT}" \
    --set service.frontendport="${FRONTEND_PORT}" \
    --set app.container.env.sysAdminEmail="${SYSADMIN_EMAIL}" \
    --set app.container.env.dbHost="${DB_HOST}" \
    --set app.container.env.dbUser="${DB_USER}" \
    --set app.container.env.dbPassword="${DB_PASSWORD}" \
    --set app.container.env.dbName="${DB_NAME}" \
    --set app.container.env.enketoApiKey="${ENKETO_API_KEY}" \
    --set networking.ingress.host="${BACKEND_APP_DOMAIN}" \
    --set networking.enketo.ingress.host="${ENKETO_DOMAIN}" \
    --set networking.frontend.ingress.host="${FRONTEND_APP_DOMAIN}" \
    --set externalDatabase.host="${DB_HOST}" \
    --set externalDatabase.user="${DB_USER}" \
    --set externalDatabase.password="${DB_PASSWORD}" \
    --set externalDatabase.name="${DB_NAME}"
    

    # --set externalDatabase.ssl="${DB_SSL}"
    # --set app.container.env.dbSSL="${DB_SSL}" \
    # --wait \
    # --timeout 300s


# source local.sh

# List pods
kubectl get pods -n odk-central-namespace

kubectl exec -it odk-central-release-67cd5b5c8-f7dvv -n odk-central-namespace -- bash
odk-cmd -u odk user-create
odk-cmd -u <email> user-promote

# Delete namesapce
kubectl delete namespace odk-central-namespace



docker run -it --entrypoint /bin/bash naturalstate/odk_service:dev-latest