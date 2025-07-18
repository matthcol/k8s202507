# Kubernetes

## Minikube
https://minikube.sigs.k8s.io/docs/start

### Management
```
minikube start
minikube status
minikube stop
minikube pause

minikube dashboard

minikube addons list
minikube addons enable metrics-server

minikube delete --all
```

### Docker in docker
```
docker ps           # minikube container
docker exec -it minikube bash
docker ps           # containers inside minikube
```

Settings to address directly dind:
```
minikube docker-env
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

minikube tunnel     # only for 'LoadBalancer' services 
kubectl get svc
```

## Supervision
- Enable metrics
```
minikube addons enable metrics-server
```

- GUI: cf dashboard

- CLI:
```
kubectl top pods
```

## Namespaces


## Yaml deployment

### Database (1 pod):
```
kubectl apply -f .\config\db.deployment.yml
kubectl get po -n blockbuster                    #  CrashLoopBackOff  
kubectl logs -n blockbuster moviedb              #  missing  POSTGRES_PASSWORD
```

Fix yaml and reapply it:

```
kubectl delete pod moviedb -n blockbuster
kubectl apply -f config/db.deployment.yml
```

Check the pod:
```
kubectl exec -it -n blockbuster moviedb -- bash  
    psql -U postgres
        \l
        \d

kubectl exec -it -n blockbuster moviedb -- psql -U postgres
```

- Init DDL+Data with copy:
```
kubectl cp -n blockbuster sql/01-tables.sql moviedb:/tmp
kubectl exec -it -n blockbuster moviedb -- ls -l /tmp
kubectl exec -it -n blockbuster moviedb -- psql -U postgres -f /tmp/01-tables.sql
```

- Init DDL+Data with config map (size limit !):
```
kubectl create cm db-sql-init -n blockbuster --from-file sql/01-tables.sql
kubectl create cm db-sql-init -n blockbuster --from-file sql

kubectl get cm -n blockbuster
kubectl describe cm db-sql-init -n blockbuster
kubectl get cm db-sql-init -n blockbuster -o jsonpath='{.data}'
```

- Config map from env file
```
kubectl create cm db-env -n blockbuster --from-env-file .env-db
kubectl get cm db-env -n blockbuster -o jsonpath='{.data}'
```

- Config map from args
```
kubectl create cm db-env2 -n blockbuster --from-literal POSTGRES_DB=dbmovie
kubectl get cm db-env -n blockbuster -o jsonpath='{.data}'
```

NB: other possibility config map with YAML file

- check the pod with init sql mounted from cm:
```
kubectl exec -it -n blockbuster moviedb -- psql -U postgres -d dbmovie
kubectl exec -it -n blockbuster moviedb -- psql -U movie -d dbmovie
kubectl logs -n blockbuster moviedb
```

- persistence with a volume claim

SQL test:
```
insert into movie (title, year) values ('Je suis une légende', 2007);
insert into person (name) values ('Will Smith');
```

Check if data exists after crash or delete:
```
kubectl delete -n blockbuster po moviedb  
kubectl apply -f .\config\db.deployment.yml  
kubectl exec -it -n blockbuster moviedb -- psql -U postgres -d dbmovie
    select * from movie;
    select * from person;
```

After adding service layer:
```
kubectl get svc,deploy,rs,pod -n blockbuster -l app=moviedb
```

### API

- Build image locally (dind):
```
docker build api-v1.0 -t movieapi:1.0
docker build api-v2.0 -t movieapi:2.0
```

- Deploy api

### Diagnostic with oneshot container client
Use a temporary container with a db client:

```
kubectl run -n blockbuster dbclient --image=postgres:17 -it --rm --restart=Never -- psql -U postgres -p 5432 -d moviedb -h  moviedb

kubectl run -n blockbuster dbclient --image=postgres:17 -it --rm --restart=Never -- bash
    psql -U postgres -p 5432 -d moviedb -h  moviedb
```

### Test Api with curl
Shell:
```
curl -X 'POST' \
  'http://localhost:8081/movies/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "Je suis une légende 3",
  "year": 2015,
  "duration": 120
}'
```

```
curl -X 'POST' \
  'http://10.96.231.155:8081/movies/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "title": "Je suis une légende 4",
  "year": 2015,
  "duration": 120
}'
```

Powershell:
```
curl -X 'POST' `
  'http://localhost:8081/movies/' `
  -H 'accept: application/json' `
  -H 'Content-Type: application/json' `
  -d '{
  "title": "Je suis une légende 3",
  "year": 2015,
  "duration": 120
}'
```
### Summary service exposition
```
minikube service --all -n blockbuster
minkube tunnel
kubectl port-forward service/echosolo-service 8082:8082
```

















