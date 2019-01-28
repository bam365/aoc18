from collections import namedtuple
import re
import sys

RectSpec = namedtuple('RectSpec', 'cols, rows, col_off, row_off')

REGEX_RECTSPEC = re.compile(r"^#(\d*) @ (\d*),(\d*): (\d*)x(\d*)")


def parse_rectspec(specstr):
    match = REGEX_RECTSPEC.match(specstr)

    def mint(n):
        return int(match.group(n))

    return RectSpec(mint(4), mint(5), mint(2), mint(3))


class CountRect:
    def __init__(self, cols, rows, v):
        self.cols = cols
        self.rows = rows
        self.rect = [[v for x in range(cols)] for y in range(rows)]

    def blit(self, rect):
        for col in range(rect.cols):
            for row in range(rect.rows):
                (r, c) = (row + rect.row_off, col + rect.col_off)
                self.rect[r][c] += 1

    def count_with(self, predicate):
        count = 0
        for col in range(self.cols):
            for row in range(self.rows):
                if predicate(self.rect[row][col]):
                    count += 1
        return count


def blit_sheet(rectspecs):
    rect = CountRect(1000, 1000, 0)
    for rectspec in rectspecs:
        rect.blit(rectspec)
    return rect


def main():
    rects = [parse_rectspec(line) for line in sys.stdin
             if line.strip() != '']
    sheet = blit_sheet(rects)
    answer = sheet.count_with(lambda n: n > 1)
    print(answer)


if __name__ == '__main__':
    main()
