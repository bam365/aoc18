from collections import namedtuple


Point = namedtuple('Point', "x, y")


def cell_power_level(point: Point, serial: int) -> int:
    rack_id = point.x + 10
    power = rack_id * point.y
    power += serial
    power *= rack_id
    hundreds_digit = 0 if power < 100 else int(str(power)[-3])
    return hundreds_digit - 5


def test_cell_power_level():
    assert cell_power_level(Point(x=3, y=5), 8) == 4
