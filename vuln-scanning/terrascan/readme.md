##

Detect compliance and security violations across Infrastructure as Code to mitigate risk before provisioning cloud native infrastructure.

[terrascan](https://runterrascan.io/)

[terrascan_github](https://github.com/tenable/terrascan)

[k8s-deploy](https://github.com/tenable/terrascan/tree/master/deploy/kustomize)

```sh

$ terrascan
Terrascan

Detect compliance and security violations across Infrastructure as Code to mitigate risk before provisioning cloud native infrastructure.
For more information, please visit https://runterrascan.io/

Usage:
  terrascan [command]

Available Commands:
  help        Provides usage info about any command
  init        Initialize Terrascan
  scan        Start scan to detect compliance and security violations across Infrastructure as Code.
  server      Run Terrascan as an API server
  version     Shows the Terrascan version you are currently using.

Flags:
  -c, --config-path string      config file path
  -h, --help                    help for terrascan
  -l, --log-level string        log level (debug, info, warn, error, panic, fatal) (default "info")
      --log-output-dir string   directory path to write the log and output files
  -x, --log-type string         log output type (console, json) (default "console")
  -o, --output string           output type (human, json, yaml, xml, junit-xml, sarif, github-sarif) (default "human")
      --temp-dir string         temporary directory path to download remote repository,module and templates

Use "terrascan [command] --help" for more information about a command.

```
##

```sh

podman build -t terrascan .
podman run --rm -it --name terrascan -v <dir/to/be/scanned>:/home/terrascan:ro -d terrascan
podman exec -it terrascan terrascan scan

```
