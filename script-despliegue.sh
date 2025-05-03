#!/bin/bash

set -e  # Finaliza ante cualquier error

# Verificar sistema operativo
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  echo "Este script debe ejecutarse en WSL o Linux."
  exit 1
fi

# Verificar comandos necesarios
for herramienta in git minikube kubectl; do
  if ! command -v "$herramienta" &> /dev/null; then
    echo "Error: '$herramienta' no está instalado."
    exit 1
  fi
done

# Definir variables
BASE="$HOME/tp-cloud-iriel"
REPO_SITIO="https://github.com/irielmoro/static-website.git"
REPO_K8S="https://github.com/irielmoro/manifiestos-k8s-repository.git"
DIR_SITIO="$BASE/static-website"
DIR_MANIFIESTOS="$BASE/manifiestos-k8s-repository"
MOUNT_PATH="/mnt/web"
PROFILE="tp-cloud"

mkdir -p "$BASE"
cd "$BASE"

# Clonar repositorios si no existen
if [[ ! -d "$DIR_SITIO" ]]; then
  git clone "$REPO_SITIO"
fi

if [[ ! -d "$DIR_MANIFIESTOS" ]]; then
  git clone "$REPO_K8S"
fi

# Iniciar Minikube con volumen
minikube delete -p "$PROFILE" >/dev/null 2>&1 || true
minikube start -p "$PROFILE" --driver=docker --mount --mount-string="${DIR_SITIO}:${MOUNT_PATH}"

# Usar contexto
if kubectl config get-contexts | grep -q "$PROFILE"; then
  kubectl config use-context "$PROFILE"
fi

# Esperar que el nodo esté listo
until kubectl get nodes &>/dev/null; do
  sleep 2
done

# Borrar recursos anteriores
kubectl delete deployment static-web-deployment --ignore-not-found
kubectl delete service static-web-service --ignore-not-found
kubectl delete pvc static-web-pvc --ignore-not-found
kubectl delete pv static-web-pv --ignore-not-found

# Aplicar manifiestos
kubectl apply -f "$DIR_MANIFIESTOS/pv.yaml"
kubectl apply -f "$DIR_MANIFIESTOS/pvc.yaml"
kubectl apply -f "$DIR_MANIFIESTOS/deployment.yaml"
kubectl apply -f "$DIR_MANIFIESTOS/service.yaml"

# Esperar que el pod esté listo
kubectl wait --for=condition=ready pod -l app=static-web --timeout=60s

# Mostrar estado
kubectl get pods
kubectl get pv,pvc

# Verificar archivos montados
kubectl exec -it "$(kubectl get pod -l app=static-web -o jsonpath="{.items[0].metadata.name}")" -- ls /usr/share/nginx/html

# Abrir sitio
minikube service static-web-service -p "$PROFILE"
