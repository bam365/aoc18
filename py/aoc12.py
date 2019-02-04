from collections import namedtuple
from io import StringIO
import re
import sys
from typing import Dict

Rules = Dict[str, str]
FlowerData = namedtuple('FlowerData', ['data', 'idx'])

NUM_GENERATIONS = 20


def trim_and_index(data: str, idx: int) -> FlowerData:
    first_ind = data.index('#')
    last_ind = data[::-1].index('#')
    new_data = data[first_ind:-last_ind]
    new_idx = idx + first_ind
    return FlowerData(data=new_data, idx=new_idx)


def generate(data: FlowerData, rules: Rules) -> FlowerData:
    # Allow for the data to expand on either side for a 5-wide rule
    pad_str = '....'
    padded_offset = 2
    ref_str = pad_str + data.data + pad_str
    out_buf = StringIO()
    for i in range(padded_offset, len(ref_str) - 2):
        substr = ref_str[i-2:i+3]
        next_c = '.'
        if substr in rules:
            next_c = rules[substr]
        out_buf.write(next_c)
    new_idx_base = data.idx - len(pad_str) + padded_offset
    return trim_and_index(out_buf.getvalue(), new_idx_base)


def generate_n(data: FlowerData, rules: Rules, n: int) -> FlowerData:
    if n < 1:
        return data
    else:
        return generate_n(generate(data, rules), rules, n - 1)


def count_flower_pots(data: FlowerData) -> int:
    count = 0
    for i, v in enumerate(data.data):
        if v == '#':
            count += i + data.idx
    return count


REGEX_INITIAL_STATE = re.compile(r"initial state: ([.#]+)")
REGEX_RULE = re.compile(r"([.#]{5}) => ([.#])")


def parse_initial_state(line: str) -> str:
    match = REGEX_INITIAL_STATE.match(line)
    return match.group(1)


def parse_rule(line: str) -> (str, str):
    match = REGEX_RULE.match(line)
    return match.group(1), match.group(2)


def parse_input(file) -> (str, Rules):
    init_state = parse_initial_state(file.readline())
    file.readline()
    rules = {}
    for line in file:
        (k, v) = parse_rule(line)
        rules[k] = v
    return init_state, rules


def main():
    (init_state, rules) = parse_input(sys.stdin)
    init_flower_data = FlowerData(init_state, idx=0)
    answer = count_flower_pots(generate_n(init_flower_data, rules, NUM_GENERATIONS))
    print(answer)


if __name__ == '__main__':
    main()


# TESTS ###################################################

class TestData:
    rules = {
        '...##': '#',
        '..#..': '#',
        '.#...': '#',
        '.#.#.': '#',
        '.#.##': '#',
        '.##..': '#',
        '.####': '#',
        '#.#.#': '#',
        '#.###': '#',
        '##.#.': '#',
        '##.##': '#',
        '###..': '#',
        '###.#': '#',
        '####.': '#'
    }

    states = [
        '#..#.#..##......###...###',
        '#...#....#.....#..#..#..#',
        '##..##...##....#..#..#..##',
        '#.#...#..#.#....#..#..#...#',
        '#.#..#...#.#...#..#..##..##',
        '#...##...#.#..#..#...#...#',
        '##.#.#....#...#..##..##..##',
        '#..###.#...##..#...#...#...#',
        '#....##.#.#.#..##..##..##..##',
        '##..#..#####....#...#...#...#',
        '#.#..#...#.##....##..##..##..##',
        '#...##...#.#...#.#...#...#...#',
        '##.#.#....#.#...#.#..##..##..##',
        '#..###.#....#.#...#....#...#...#',
        '#....##.#....#.#..##...##..##..##',
        '##..#..#.#....#....#..#.#...#...#',
        '#.#..#...#.#...##...#...#.#..##..##',
        '#...##...#.#.#.#...##...#....#...#',
        '##.#.#....#####.#.#.#...##...##..##',
        '#..###.#..#.#.#######.#.#.#..#.#...#',
        '#....##....#####...#######....#.#..##'
    ]

    initial = FlowerData(states[0], idx=0)


def test_generate():
    state = TestData.initial
    for i in range(0, len(TestData.states) - 1):
        state = generate(state, TestData.rules)
        assert state.data == TestData.states[i + 1]
    assert state.idx == -2


def test_count_flower_pots():
    data = generate_n(TestData.initial, TestData.rules, NUM_GENERATIONS)
    assert count_flower_pots(data) == 325
