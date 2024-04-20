docker build . --file Dockerfile.velocity --tag v --no-cache
docker build . --file Dockerfile.base --tag t --no-cache
docker build . --file Dockerfile.plot --tag p --no-cache