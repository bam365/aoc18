from collections import namedtuple
import sys


Node = namedtuple('Node', ['metadata', 'children'])


def parse_node(stream):
    child_count = int(next(stream))
    metadata_count = int(next(stream))
    # Seems like there should be a better way to do this...
    children = [parse_node(stream) for i in range(0, child_count)]
    metadata = [int(next(stream)) for i in range(0, metadata_count)]
    return Node(metadata, children)


def sum_metadata(node):
    child_sums = [sum_metadata(node) for node in node.children]
    return sum(node.metadata) + sum(child_sums)


def parse_stream(f):
    return f.read().split()


def main():
    stream = parse_stream(sys.stdin)
    node = parse_node(iter(stream))
    answer = sum_metadata(node)
    print(answer)


if __name__ == '__main__':
    main()
