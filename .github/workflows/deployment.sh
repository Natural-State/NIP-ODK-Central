
#!/bin/bash


# Usage examples:
# deploy_odk_central "app-name" "odk-central-namespace" "odk-central-release" "example.com" "tls-secret" "mapbox-api-key" "db-host" "db-username" "db-password"

# Function to deploy odk-central
deploy_odk_central() {
    HELM_RELEASE="$1"
    DOMAIN_NAME="$2"
    TLS_SECRET_NAME="$3"
    DB_HOST="$4"
    DB_USER="$5"
    DB_PASSWORD="$6"
    ARM_TENANT_ID="$7"
    POSTGRES_SECRET_NAME="$8"
    PGPASSWORD="$9"
    ODK_CENTRAL_USERNAME="${10}"
    ODK_CENTRAL_PASSWORD="${11}"
    
    echo "Helm release: $HELM_RELEASE"
    echo "Domain name: $DOMAIN_NAME"
    echo "TLS Secret: $TLS_SECRET_NAME"
    echo "POSTGRES_SECRET_NAME: $POSTGRES_SECRET_NAME"

    # Helm dependency update
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
    --set externalDatabase.name="${DB_NAME}" \
    --wait \
    --timeout 300s
    
}
    # --set app.container.env.dbSSL="${DB_SSL}" \
    # --set networking.issuer.name="letsencrypt-prod" \
    # --set networking.issuer.privateKeySecretRef="letsencrypt-prod" \

    # --set "global.pgConfig.host=$DB_HOST" \
    # --set "global.pgConfig.userName=$DB_USER" \
    # --set "global.pgConfig.password.secretName=$POSTGRES_SECRET_NAME" \
    # --set "global.pgConfig.password.secretKey=pgpassword" \
    # --set "app.ingress.host=$DOMAIN_NAME" \
    # --set "app.ingress.tls[0].hosts[0]=$DOMAIN_NAME" \
    # --set "app.ingress.tls[0].secretName=ingress-tls-odk-central" \
    # --set "global.extraEnvironmentVars.ODK_CENTRAL_USERNAME=$ODK_CENTRAL_USERNAME" \
    # --set "global.extraEnvironmentVars.ODK_CENTRAL_PASSWORD=$ODK_CENTRAL_PASSWORD" \
    # --debug