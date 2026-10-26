@echo off
echo Criando as imagens........

docker build -t projeto-backend:1.0 backend/.
docker build -t projeto-database:1.0 database/.

echo Criando servicos no cluster kubernetes...

kubectl apply -f ./services.yml

echo Criando os deployments......

kubectl apply -f ./deployment.yml
