# Kubernetes

## Minikube
https://minikube.sigs.k8s.io/docs/start

### Management
minikube start
minkube status
minikube stop

### Docker in docker
```
docker ps           # => minikube container
docker exec -it minikube bash
docker ps
```

## CLI: kubectl
```
kubectl version             # host (to download)
minikube kubectl version    # inside minikube
```

Alias:
```
alias kubectl="minikube kubectl --"
```

### List of applications (pod, replica set, deployment, service)
```
kubectl get all

kubectl get pods
kubectl get pod
kubectl get po
kubectl get po -A       # all namespaces
```

## Deployment 
### Oneshot: run
- Echo
```
kubectl run echosolo --image=kicbase/echo-server:1.0
kubectl get po

kubectl delete po echosolo
kubectl delete pod/echosolo
```

- Nginx
```
kubectl run nginx --image=nginx:latest
```

### Deployment with replica set
```
kubectl create deployment echomirror --image=kicbase/echo-server:1.0 --replicas=3
kubectl get all

kubectl get deployments
kubectl get deployment
kubectl get deploy

kubectl get replicasets
kubectl get replicaset
kubectl get rs

kubectl get po,rs,deploy

kubectl get po,rs,deploy -o wide

kubectl delete deployment echomirror
```

## Exec command
```
kubectl exec -it nginx -- bash
```

## Scaling
```
kubectl scale deployment echomirror --replicas=5
kubectl get po,rs,deploy

kubectl scale deployment echomirror --replicas=5

kubectl scale deployment echomirror --replicas=0  # stop/pause
```

## Label
https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/

```
kubectl get po,rs,deploy --show-labels
kubectl get po,rs,deploy -l app=echomirror

kubectl label pod/echosolo service=echo
kubectl label po,rs,deploy -l app=echomirror service=echo

kubectl get all -l service=echo

kubectl label po,rs,deploy -l app=echomirror dummy=dumber
# unlabel:
kubectl label po,rs,deploy -l dummy=dumber dummy- 

# change label:
kubectl label pod/nginx --overwrite type=reverse-proxy
```

## Recap get
```
kubectl get po,rs
kubectl get po,rs --show-labels
kubectl get po,rs -o wide
kubectl get po,rs -o json
kubectl get pod/nginx -o jsonpath="{..image}" 
```

## Service
- type ClusterIP
```
kubectl expose pod nginx --type=ClusterIP --port 80  --name nginx-service
```   

- type NodePort
```
kubectl expose pod echosolo --type=NodePort --port 8080  --name echosolo-service   
kubectl delete svc echosolo-service    #  service only 
kubectl expose pod echosolo --type=NodePort --port 8082 --target-port 8080  --name echosolo-service

kubectl port-forward service/echosolo-service 8082:8082
```

- type LoadBalancer
```
kubectl expose deployment echomirror --type=LoadBalancer --port 8080  --name echomirror-service

minikube tunnel
kubectl get svc
```


