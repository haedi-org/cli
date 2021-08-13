# edi-cli
CLI for EDI parsing, validation and manipulation

```
Usage:
 ./edi-cli.exe [options] [arguments]

Arguments:
 paths              One or more path to an EDI file

Options:
 -u  --unit         Parse and display unit test results
 -p  --parse        Parse and display segment reference data
 -d  --debug        Attempt to parse file and display cropped data
 -s  --structure    Parse and display EDI document structure
 -t  --timeline     Parse and display chronological information
 -l  --headless     Continually read-in paths without terminal
 -e  --edicate      HTML output compatible with Edicate EDI client
```

### Building

Requires [OCRA (One-Click Ruby Application)](https://github.com/larsch/ocra)

```
git clone "https://github.com/mejszin/edi-cli"
cd edi-cli/
rake build
```

### Example

Run example EDI message unit tests with ```rake test```

```
----------------------------------------------------------------------
CLI for EDI parsing, validation and manipulation                v0.1.0
----------------------------------------------------------------------

Scenario 01. [mssge_bad_0.edi]
  ✓ valid segment terminator
  ✗ unknown message type 'INVXXX'
  ✓ valid message segments
  ✓ complete envelopes

Scenario 02. [mssge_bad_1.edi]
  ✓ valid segment terminator
  ✗ empty message type
  ✓ valid message segments
  ✓ complete envelopes

Scenario 03. [mssge_bad_2.edi]
  ✓ valid segment terminator
  ✓ valid message type
  ✓ valid message segments
  ✗ invalid 'UNHUNT' envelope

Scenario 04. [mssge_bad_3.edi]
  ✓ valid segment terminator
  ✓ valid message type
  ✓ valid message segments
  ✗ invalid 'UNBUNZ' envelope

Scenario 05. [punct_bad_0.edi]
  ✗ invalid segment terminator

Scenario 06. [punct_bad_1.edi]
  ✗ invalid segment terminator

Scenario 07. [punct_bad_2.edi]
  ✗ invalid 'UNA' segment

Scenario 08. [punct_good_0.edi]
  ✓ valid segment terminator
  ✓ valid message type

Scenario 09. [punct_good_1.edi]
  ✓ valid segment terminator
  ✓ valid message segments
  ✓ complete envelopes

Scenario 10. [punct_good_2.edi]
  ✓ valid segment terminator
  ✓ valid message type
  ✓ valid message segments
  ✓ complete envelopes

Scenario 11. [segmt_bad_0.edi]
  ✓ valid segment terminator
  ✓ valid message type
  ✗ unknown message segment 'LXN'
  ✓ complete envelopes

Completed 11 scenario(s).
3 passed; 8 failed.
```
