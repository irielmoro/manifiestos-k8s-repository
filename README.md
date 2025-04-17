# TP 0311AT – Kubernetes: Casi como en producción  
**Autor:** Iriel Moro – ITU UNCuyo – Desarrollo de Software

---

## Objetivo

Desplegar un sitio web estático dentro de un clúster de Kubernetes local (Minikube), **montando los archivos desde un volumen persistente (hostPath)** y sirviéndolos con Nginx.  
El objetivo principal es **simular un entorno de producción real sin construir imágenes personalizadas.**

----

## Requisitos previos

- Git
- Docker Desktop (con Kubernetes habilitado, si es posible)
- Minikube
- kubectl
- Git Bash o terminal CMD con permisos de administrador

----

## Estructura del proyecto

Se utilizan **dos repositorios separados**:

1. [`static-website`](https://github.com/irielmoro/static-web): contiene los archivos del sitio (`index.html`, `style.css`, `assets/`)
2. [`k8s-manifiestos`](https://github.com/irielmoro/manifiestos-k8s-repository): contiene los manifiestos de Kubernetes (`pv.yaml`, `pvc.yaml`, `deployment.yaml`, `service.yaml`, `README.md`)

----

## Instrucciones paso a paso

### 1. Crear una carpeta de trabajo y clonar los repos

```bash
mkdir tp-cloud && cd tp-cloud

git clone https://github.com/irielmoro/static-web.git
git clone https://github.com/irielmoro/manifiestos-k8s-repository.git
```

### 2. Iniciar Minikube montando el sitio como volumen
Este paso monta la carpeta del sitio web en el nodo de Minikube, usando hostPath.

```bash
minikube start -p tp-cloud --driver=docker --mount --mount-string="C:/ruta/completa/a/static-web:/mnt/web"
```
NOTA: Reemplazá C:/ruta/completa/a/static-web por la ruta real donde clonaste el repo.


### 3. Aplicar los manifiestos de Kubernetes
Desde la carpeta manifiestos-k8s-repository, ejecutá:

```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 4. Verificar que todo esté funcionando

```bash
kubectl get all
kubectl get pv,pvc
```
NOTA: 
- El PVC static-web-pvc debe estar Bound al PV static-web-pv.
- El pod debe estar en estado Running.


### 5. Verificar que los archivos fueron montados

```bash
kubectl exec -it deploy/static-web-deployment -- ls /usr/share/nginx/html
```
NOTA: Deberías ver: index.html, style.css, assets/


### 6. Acceder al sitio web
Este proyecto expone el sitio web mediante un `Service` de tipo `NodePort`. Según el sistema operativo y la configuración del entorno, hay *dos formas de acceder* al sitio:

# Opción A: `port-forward` (recomendada en Windows)
Ideal para Windows o cuando usás Minikube con driver Docker. Redirige tráfico local al clúster.

```bash
kubectl port-forward service/static-web-service 8080:80
```

Luego abrí en tu navegador:

```bash
http://localhost:8080
```

# Opción B: Acceso directo vía `NodePort` (Linux/macOS o drivers VM)
Si tu entorno lo permite (por ejemplo, estás en Linux o usás Minikube con VirtualBox o Hyper-V), podés acceder directamente al puerto publicado:

1. Obtener la IP del nodo:

```bash
minikube ip -p tp-cloud
```

2. Abrir en el navegador:

```bash
http://<IP_DEL_NODO>:30036
```
*Ejemplo:*
Si minikube ip devuelve 192.168.49.2, accedé a: *http://192.168.49.2:30036*

**NOTA:**
En caso de duda, port-forward funciona siempre, sin importar el sistema operativo.


### Resultado esperado
La web se carga correctamente en el navegador, mostrando el contenido del archivo index.html, servido por Nginx, desde el volumen persistente montado.


----


## Autor

**Iriel Moro**  
Estudiante de Desarrollo de Software  
Instituto Tecnológico Universitario – UNCuyo
