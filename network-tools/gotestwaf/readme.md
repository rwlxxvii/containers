## Wallarm gotestwaf

[github](https://github.com/wallarm/gotestwaf)

```sh

podman build -t gotestwaf .
podman run --rm --network=host -v ${PWD}/reports:/home/gotestwaf/reports \
           gotestwaf --url=<EVALUATED_SECURITY_SOLUTION_URL> --noEmailReport

```
