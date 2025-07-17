kubectl create ns blockbuster
kubectl create cm db-env -n blockbuster --from-env-file .env-db
kubectl create cm db-sql-init -n blockbuster --from-file sql
kubectl apply -f config/db.volume.yml
kubectl apply -f config/db.deployment.yml
