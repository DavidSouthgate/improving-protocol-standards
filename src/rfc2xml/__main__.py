from lxml import etree
import sys
from . import Rfc2Xml


def main():
    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    filename = sys.argv[1]
    suppress_result = False

    for arg in sys.argv[2:]:
        if arg == "--suppress-result":
            suppress_result = True
        else:
            print("Unknown argument", arg)
            usage()
            sys.exit(2)

    with open(filename) as fp:
        contents = fp.read()

    result = Rfc2Xml.parse(contents).to_xml()

    if not suppress_result:
        print(etree.tostring(result, pretty_print=True).decode())


def usage():
    print("Usage: python -m rfc2xml <filename> [--suppress-result]", file=sys.stderr)


if __name__ == "__main__":
    main()
