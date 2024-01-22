```sh

   _____ _                 _  _____       _       _ _   
  / ____| |               | |/ ____|     | |     (_) |  
 | |    | | ___  _   _  __| | (___  _ __ | | ___  _| |_ 
 | |    | |/ _ \| | | |/ _` |\___ \| '_ \| |/ _ \| | __|
 | |____| | (_) | |_| | (_| |____) | |_) | | (_) | | |_ 
  \_____|_|\___/ \__,_|\__,_|_____/| .__/|_|\___/|_|\__|
                                   | |                  
                                   |_|                  

  CloudSploit by Aqua Security, Ltd.
  Cloud security auditing for AWS, Azure, GCP, Oracle, and GitHub

usage: index.js [-h] [--config CONFIG] [--compliance {hipaa,cis,cis1,cis2,pci}] [--plugin PLUGIN] [--govcloud]
                [--china] [--csv CSV] [--json JSON] [--junit JUNIT] [--console {none,text,table}]
                [--collection COLLECTION] [--ignore-ok] [--exit-code] [--skip-paginate] [--suppress SUPPRESS]
                [--remediate REMEDIATE] [--cloud {aws,azure,github,google,oracle,alibaba}] [--run-asl]

optional arguments:
  -h, --help            show this help message and exit
  --config CONFIG       The path to a CloudSploit config file containing cloud credentials. See
                        config_example.js. If not provided, logic will use default AWS credential chain and will
                        also override provided cloud
  --compliance {hipaa,cis,cis1,cis2,pci}
                        Compliance mode. Only return results applicable to the selected program.
  --plugin PLUGIN       A specific plugin to run. If none provided, all plugins will be run. Obtain from the
                        exports.js file. E.g. acmValidation
  --govcloud            AWS only. Enables GovCloud mode.
  --china               AWS only. Enables AWS China mode.
  --csv CSV             Output: CSV file
  --json JSON           Output: JSON file
  --junit JUNIT         Output: Junit file
  --console {none,text,table}
                        Console output format. Default: table
  --collection COLLECTION
                        Output: full collection JSON as file
  --ignore-ok           Ignore passing (OK) results
  --exit-code           Exits with a non-zero status code if non-passing results are found
  --skip-paginate       AWS only. Skips pagination (for debugging).
  --suppress SUPPRESS   Suppress results matching the provided Regex. Format: pluginId:region:resourceId
  --remediate REMEDIATE
                        Run remediation the provided plugin
  --cloud {aws,azure,github,google,oracle,alibaba}
                        The name of cloud to run plugins for. If not provided, logic will assume cloud from
                        config.js file based on provided credentials
  --run-asl             When set, it will execute custom plugins.


# build and run example

docker|podman build -t cloudsploit .

docker|podman run --rm -it --name cloudsploit \
    --config /cloudsploit/config.js \
    --compliance {hipaa,cis,cis1,cis2,pci} \
    --cloud {aws,azure,github,google,oracle,alibaba} \
    --{csv,json,junit}
```