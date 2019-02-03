import sys
from rfc2xml import Rfc2Xml
from . import ExtendedDiagrams, Parse
from protocol import Protocol

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

    extended_diagrams = ExtendedDiagrams(filename)
    extended_diagrams.traverse_dom()



    #protocol = extended_diagrams.protocol()
    #print(protocol)

    result = None
    if not suppress_result:
        print(extended_diagrams.dom)


def usage():
    print("Usage: python -m input_parsers.extended_diagrams [--suppress-result]", file=sys.stderr)


if __name__ == "__main__":
    main()
