docker build . --file Dockerfile.base --tag ghcr.io/erik1000/minecraft-server-docker:base-latest --no-cache
docker build . --file Dockerfile.velocity --tag ghcr.io/erik1000/minecraft-server-docker:velocity-latest --no-cache
docker build . --file Dockerfile.plot --tag ghcr.io/erik1000/minecraft-server-docker:plot-latest --no-cache