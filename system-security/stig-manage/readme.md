## stig-manager

Save a bunch of exhausting hours of STIG review/updates using this open source solution similiar to "eMASSter" if you ever used it before.

```sh

# instruct: build locally -

tar zxvf client.tar.xz

./client/build.sh

./docs/build.sh

podman build -t stig-manager .

```

```sh

# instruct: compose using NUWC-Newport image, with nginx reverse proxy and keycloak for CAC auth -

cd compose

# fill out env variables

vim .env

# generate crt/key

cd ../certs/sslfrontend

# steps in generate.md, replace CA/CSR subject, cut cert/key from CA

# compose up

cd ../..

podman-compose up -d

```

https://stig-manager.readthedocs.io/en/latest/index.html


eMASSter:

https://spork.navsea.navy.mil/RMF-Automation/emasster

only accessible from DoD networks, required CAC/PIV logon.
