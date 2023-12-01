```sh
# as user "kaniko"
systemctl --user enable podman.socket

# verify socket is enabled
podman info | grep -i -A 2 remoteSocket

# test socket
sudo curl -H "Content-Type: application/json" --unix-socket \
/var/run/podman/podman.sock http://localhost/_ping

# build image that will then push anchore Dockerfile via kaniko
podman build -t kaniko-anchore-push .

# docker in podman, the ant-man way.
podman run --rm -it --name kaniko-push -v $XDG_RUNTIME_DIR/podman/podman.sock:/var/run/docker.sock:ro -v /etc/localtime:/etc/localtime:ro -d kaniko-anchore-push
```
