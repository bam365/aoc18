from collections import namedtuple
import sys

import aoclib

Node = namedtuple('Node', ['metadata', 'children'])


def parse_node(stream):
    child_count = int(next(stream))
    metadata_count = int(next(stream))
    children = [parse_node(stream) for i in range(0, child_count)]
    metadata = [int(next(stream)) for i in range(0, metadata_count)]
    return Node(metadata, children)


def sum_metadata(node):
    child_sums = [sum_metadata(node) for node in node.children]
    return sum(node.metadata) + sum(child_sums)


def parse_stream(f):
    return f.read().split()


def main():
    stream = aoclib.int_stream(sys.stdin)
    answer = sum_metadata(parse_node(stream))
    print(answer)


if __name__ == '__main__':
    main()
