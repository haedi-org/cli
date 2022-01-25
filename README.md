# edi-cli
CLI for EDI parsing, validation and manipulation

```
Usage:
 ./haedi.exe [options] [arguments]

Arguments:
 paths              One or more path to an EDI file

Options:
 -u  --unit         Parse and display unit test results
 -i  --info         Parse and display critical information
 -p  --parse        Parse and display segment reference data
 -d  --debug        Attempt to parse file and display cropped data
 -s  --structure    Parse and display EDI document structure
 -t  --timeline     Parse and display chronological information
 -c  --collection   List files given with general document information
 -l  --headless     Continually read-in paths without terminal
 --html             HTML output compatible with EDI client
```

### Building

- Requires [Bundler](https://bundler.io/)
- Requires [OCRA (One-Click Ruby Application)](https://github.com/larsch/ocra)

```
git clone "https://github.com/haedi-org/cli"
cd cli/
bundle install
rake build
```
