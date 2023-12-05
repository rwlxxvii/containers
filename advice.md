## after building image -

```sh
# prune build environment
docker|podman image prune -f

# squash final image
pip install --user https://github.com/goldmann/docker-squash/archive/master.zip

# example
docker-squash -f 4bb15f3b6977 -t jboss/wildfly:squashed jboss/wildfly:latest

# usage
$ docker-squash -h
usage: cli.py [-h] [-v] [--version] [-d] [-f FROM_LAYER] [-t TAG]
              [--tmp-dir TMP_DIR] [--output-path OUTPUT_PATH]
              image

Docker layer squashing tool

positional arguments:
  image                 Image to be squashed

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         Verbose output
  --version             Show version and exit
  -d, --development     Does not clean up after failure for easier debugging
  -f FROM_LAYER, --from-layer FROM_LAYER
                        Number of layers to squash or ID of the layer (or image ID or image name) to squash from.
                        In case the provided value is an integer, specified number of layers will be squashed.
                        Every layer in the image will be squashed if the parameter is not provided.
  -t TAG, --tag TAG     Specify the tag to be used for the new image. If not specified no tag will be applied
  -m MESSAGE, --message MESSAGE
                        Specify a commit message (comment) for the new image.
  -c, --cleanup         Remove source image from Docker after squashing
  --tmp-dir TMP_DIR     Temporary directory to be created and used
  --output-path OUTPUT_PATH
                        Path where the image may be stored after squashing.
  --load-image [LOAD_IMAGE]
                        Whether to load the image into Docker daemon after squashing
                        Default: true

# save container as OCI image
docker|podman save -o oci-<image name>.tar --format oci-archive <image name>

# load to repository
docker|podman load -q -i oci-<image name>.tar
```