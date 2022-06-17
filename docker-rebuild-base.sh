TAG=docker.io/ethcomsec/cellift-chipyard-base:cellift-chipyard-base
docker build -t $TAG -f Dockerfile-base .
echo "docker push $TAG"
