#!/bin/bash

# set -eo pipefail

# Default values if not provided as arguments
# namespace="labelstudio-namespace"
# tls_secret_name=""
crt_path="./tls.crt"
key_path="./tls.key"
# TLS_CRT=""
# TLS_KEY=""
# postgres_secret_name=""
# PGPASSWORD=""

# Function to display usage instructions
# usage() {
#     cat <<EOF
# Usage: $0 [OPTIONS]
# Options:
#   -n, --namespace            Kubernetes Namespace
#   -tls, --tls-secret-name    TLS Secret Name
#   --tls-crt                  Base64-encoded TLS Certificate
#   --tls-key                  Base64-encoded TLS Key
#   -pst, --postgres-secret    Postgres Secret Name
#   -pgp, --postgres-password  Postgres Password
# EOF
#     exit 1
# }

# Parse command-line arguments
# while [[ $# -gt 0 ]]; do
#     case "$1" in
#         -n|--namespace)
#             namespace="$2"; shift 2;;
#         -tls|--tls-secret-name)
#             tls_secret_name="$2"; shift 2;;
#         --tls-crt)
#             TLS_CRT="$2"; shift 2;;
#         --tls-key)
#             TLS_KEY="$2"; shift 2;;
#         -pst|--postgres-secret)
#             postgres_secret_name="$2"; shift 2;;
#         -pgp|--postgres-password)
#             PGPASSWORD="$2"; shift 2;;
#         *)
#             usage;;
#     esac
# done

# Check if required arguments are provided
# if [ -z "$namespace" ] || [ -z "$tls_secret_name" ] || [ -z "$TLS_CRT" ] || [ -z "$TLS_KEY" ] || [ -z "$postgres_secret_name" ] || [ -z "$PGPASSWORD" ]; then
#     echo "Error: Missing required arguments."
#     usage
# fi

# Ensure namespace exists
echo "Namespace: $namespace"
if ! kubectl get namespace "$namespace" &>/dev/null; then
    echo "Creating namespace $namespace"
    kubectl create namespace "$namespace"
else
    echo "Namespace $namespace already exists"
fi

# Decode and save TLS certificate and key
echo "$TLS_CRT" | base64 -d > "$crt_path"
echo "$TLS_KEY" | base64 -d > "$key_path"

# Ensure TLS secret exists
if ! kubectl get secret "$tls_secret_name" -n "$namespace" &>/dev/null; then
    echo "Creating TLS secret $tls_secret_name"
    kubectl create secret tls "$tls_secret_name" --cert="$crt_path" --key="$key_path" --namespace "$namespace"
else
    echo "TLS secret $tls_secret_name already exists"
fi

# Ensure enketo secret exists
if ! kubectl get secret "$ENKETO_API_NAME" -n "$namespace" &>/dev/null; then
    echo "Creating Enketo secret $ENKETO_API_NAME"
    kubectl create secret generic "$ENKETO_API_NAME" --from-literal=enketo-api-key="$ENKETO_API_KEY" --namespace "$namespace"
else
    echo "Enketo secret $ENKETO_API_NAME already exists"
fi

# Ensure Postgres secret exists
# if ! kubectl get secret "$postgres_secret_name" -n "$namespace" &>/dev/null; then
#     echo "Creating Postgres secret $postgres_secret_name"
#     kubectl create secret generic "$postgres_secret_name" --from-literal=pgpassword="$PGPASSWORD" --namespace "$namespace"
# else
#     echo "Postgres secret $postgres_secret_name already exists"
# fi
