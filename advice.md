## setting up the environment docker|podman
```sh
# docker
### ubuntu/debian
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

### rhel/alma/oracle/rocky
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf update -y
sudo dnf install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# podman

### ubuntu/debian
sudo apt install -y podman podman-compose

### rhel/alma/oracle/rocky
sudo dnf install -y epel-release
sudo dnf update -y
sudo dnf install -y podman podman-compose
```
## building docker images
```sh
cd /dir/with/Dockerfile
docker|podman build -t <name of image> .

# podman defaults to OCI format, to change to docker image format
podman build -t <name of image> --format=docker .
```
## composing up
```sh
docker|podman-compose up -f <compose.yml> -d
```
## running image as container
```sh
# most images can be ran within a users namespace and not as root, unless host capabilities need to be added for runtime.
docker|podman run --rm -it --name <name of container> \
  -v <bind volume>:<bind volume> \
  -p <port mappings>:<port mappings> \
  -d <name of image>:<tag>
```
## after building image -
```sh
# prune build environment
docker|podman image prune -f

# squash final image
dnf|apt install -y python3 python3-pip
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