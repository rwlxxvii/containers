
```sh

podman build -t kube-bench .

podman run --rm -it \
            --pid=host \
            -v /etc:/etc:ro \
            -v /var:/var:ro \
            -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
            -v ~/.kube:/.kube \
            -e KUBECONFIG=/.kube/config \
            --name kube-bench kube-bench

```
