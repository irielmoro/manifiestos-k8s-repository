# TP 0311AT – Kubernetes: Casi como en producción  - Iriel Moro

Este trabajo práctico tiene como objetivo desplegar un sitio web estático dentro de un clúster de Kubernetes local (Minikube), simulando un entorno de producción real.


## Repositorios utilizados

- Este repositorio `manifiestos-k8s-repository` contiene los manifiestos de Kubernetes (deployment y service).

- El repositorio complementario `static-website` contiene el sitio web estático y el `Dockerfile` necesario para construir la imagen:
-> [Repositorio del sitio web estático](https://github.com/irielmoro/static-web)


## Objetivos alcanzados
- Construcción de una imagen Docker personalizada basada en Nginx
- Despliegue con Kubernetes utilizando Deployment
- Exposición del sitio mediante un Service
- Acceso desde navegador usando port-forward
- Reemplazo de `hostPath` por una solución portable y profesional con Docker


## Requisitos
- Docker Desktop
- Minikube
- kubectl
- Git Bash o CMD


## Estructura del proyecto
- static-website/: Contiene el sitio web estático (HTML, CSS, assets) 
- Dockerfile: Dockerfile que construye la imagen
- deployment.yaml: Manifiesto Kubernetes para el Deployment
- service.yaml: Manifiesto Kubernetes para el Service
- README.md: Este archivo

----

## Pasos para ejecutar el proyecto

**1. Clonar y construir la imagen del sitio web**

```bash
git clone https://github.com/irielmoro/static-web.git
cd static-web
docker build -t static-web:v1 .
minikube image load static-web:v1 -p tp-cloud
```

**2. Iniciar Minikube**

```bash
minikube start -p tp-cloud --driver=docker --addons=ingress
```
- Asegurarse de que el perfil tp-cloud esté funcionando correctamente.
----

**3. Clonar este repositorio de manifiestos**
```bash
git clone https://github.com/irielmoro/k8s-manifiestos.git
cd k8s-manifiestos
```
----

**4. Aplicar los manifiestos**

```bash
kubectl apply -f service.yaml
kubectl apply -f deployment.yaml
```
----

**5. Verificar los recursos**

```bash
kubectl get all
```
----

**6. Acceder al sitio web (con port-forward)**

```bash
kubectl port-forward service/static-web-service 8080:80
```
- Abrir el navegador y colocar:

```bash
http://localhost:8080
```
----


## Aprendizajes

Durante el desarrollo del trabajo enfrenté problemas comunes como errores de conexión (`ERR_CONNECTION_REFUSED`), o el clásico error 403 Forbidden, fallos en el montaje de volúmenes (`hostPath` vacío), complicaciones al descomprimir de manera eficiente el .tar para copiar el sitio web a minikube y conflictos con rutas de archivos en Windows. Esto me permitió:

- Comprender cómo Kubernetes monta volúmenes
- Comparar distintas estrategias (`hostPath`, `emptyDir`, `initContainer`, imágenes personalizadas)
- Consolidar el flujo completo: construir imagen → cargar en clúster → desplegar → exponer

----

## Autor

**Iriel Moro**  
Estudiante de Desarrollo de Software  
Instituto Tecnológico Universitario – UNCuyo
