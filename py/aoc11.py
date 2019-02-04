from collections import namedtuple
from aoclib import int_stream
import sys


GRID_WIDTH = 300
GRID_HEIGHT = 300

Point = namedtuple('Point', "x, y")


def cell_power_level(point: Point, serial: int) -> int:
    rack_id = point.x + 10
    power = rack_id * point.y
    power += serial
    power *= rack_id
    hundreds_digit = 0 if power < 100 else int(str(power)[-3])
    return hundreds_digit - 5


def subsquare_power(point: Point, serial: int) -> int:
    powers = (cell_power_level(Point(x=x, y=y), serial)
              for x in range(point.x, point.x + 3)
              for y in range(point.y, point.y + 3))
    return sum(powers)


def max_subsquare_power(width: int, height: int, serial: int) -> Point:
    points = (Point(x=x, y=y)
              for x in range(1, width - 3)
              for y in range(1, height - 3))

    return max(points, key=lambda point: subsquare_power(point, serial))


def main():
    nums = int_stream(sys.stdin)
    serial = next(nums)
    answer = max_subsquare_power(GRID_WIDTH, GRID_HEIGHT, serial)
    print(f"{answer.x},{answer.y}")


if __name__ == '__main__':
    main()

## TESTS ###################################################

def test_cell_power_level():
    assert cell_power_level(Point(x=3, y=5), 8) == 4
    assert cell_power_level(Point(x=122, y=79), 57) == -5
    assert cell_power_level(Point(x=217, y=196), 39) == 0
    assert cell_power_level(Point(x=101, y=153), 71) == 4
