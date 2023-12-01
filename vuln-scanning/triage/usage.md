
```sh

$ triage -help
Usage of triage:

  authenticate [token] [flags]

    Stores credentials for Triage.

  submit [url/file] [flags]

    Submit a new sample file or URL.

  select-profile [sample]

    Interactively lets you select profiles for samples that have been submitted
    in interactive mode. If an archive file was submitted, you will also be
    prompted to select the files to analyze from the archive.

  list [flags]

    Show the latest samples that have been submitted.

  file [sample] [task] [file] [flags]

    Download task related files.

  archive [sample] [flags]

    Download all task related files as an archive.

  delete [sample]

    Delete a sample.

  report [sample] [flags]

    Query reports for a (finished) analysis.

  create-profile [flags]

  delete-profile [flags]

  list-profiles [flags]

```

##

```sh

podman build -t triage .
podman run --rm -it --name triage -v <file/dir/to/be/analyzed>:/home/triage/files -d triage
for file in $(find /file/dir/to/be/analyzed -type f -name '*'); do podman exec -it sh -c "triage submit $file"; done

```
