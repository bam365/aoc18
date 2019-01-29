import re
import sys


def make_dep_graph(steps):
    graph = {}
    for (name, preceding) in steps:
        if name in graph:
            graph[name].add(preceding)
        else:
            graph[name] = set([preceding])
        if preceding not in graph:
            graph[preceding] = set()
    return graph


class GraphIterator:
    def __init__(self, graph):
        self.graph = graph.copy()

    def remove_item(self, item):
        for (k, v) in self.graph.items():
            self.graph[k] = v.difference(set([item]))
        del self.graph[item]

    def __iter__(self):
        return self

    def __next__(self):
        keys = sorted([k for (k, v) in self.graph.items() if len(v) == 0])
        if len(keys) > 0:
            ret = keys[0]
            self.remove_item(ret)
            return ret
        else:
            raise StopIteration()


STEP_REGEX = re.compile(r"Step (.) must be finished before step (.) can begin.")


def parse_dependency(s):
    match = STEP_REGEX.match(s)
    return (match.group(2), match.group(1))


def parse_dependencies(f):
    return [parse_dependency(line) for line in f]


def main():
    deps = parse_dependencies(sys.stdin)
    graph = make_dep_graph(deps)
    steps = [step for step in GraphIterator(graph)]
    answer = ''.join(steps)
    print(answer)


if __name__ == '__main__':
    main()
