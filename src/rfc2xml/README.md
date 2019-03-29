# rfc2xml
Tool to process an RFC or Internet Standard into XML or a DOM structure for document processing.

Note that this is not a general purpose tool and contains some restrictions.

## Usage
```bash
python -m rfc2xml <filename> [--suppress-result]
```

## Examples
Download an Internet Standard to process:
```bash
wget https://www.ietf.org/id/draft-ietf-quic-transport-19.txt
```

The tool can then be run on that file using the following command (in the top level src directory):
```bash
python -m rfc2xml draft-ietf-quic-transport-19.txt
```

## Import
The tool can also be imported into a different python script and used there:

```python
from rfc2xml import Rfc2Xml
with open("draft-ietf-quic-transport-19.txt") as fp:
    contents = fp.read()
dom = Rfc2Xml.parse(contents)
```