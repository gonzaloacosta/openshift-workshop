Docker Build
```
sudo docker build -t node-vanilla .
```
Docker Run
```
sudo docker run -p 3000:3000 -ti --rm --init node-vanilla
```
Buildah Build
```
sudo buildah bud -t node-vanilla .
```
Podman Run
```
sudo podman run -p 3000:3000 -ti --rm --init node-vanilla
```