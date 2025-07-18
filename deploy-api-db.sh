kubectl create ns blockbuster

kubectl create cm db-env -n blockbuster --from-env-file .env-db
kubectl create cm db-sql-init -n blockbuster --from-file sql
kubectl create secret generic db-secret --from-literal=DB_USER=moviefan  '--from-literal=DB_PASSWORD=qlhdAA#%!32' -n blockbuster

kubectl apply -f config/db.volume.yml
kubectl apply -f config/db.deployment.yml
kubectl apply -f config/db.service.yml

kubectl apply -f config/api.deployment.yml
kubectl apply -f config/api.service.yml
