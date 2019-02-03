from ast import literal_eval


def read_ints(file):
    return [int(line.strip()) for line in file]


def read_point(s):
    """Make a tuple from a string, just uses ast.literal_eval"""
    return literal_eval(s)


def int_stream(file):
    for line in file:
        for item in line.split():
            yield int(item)
