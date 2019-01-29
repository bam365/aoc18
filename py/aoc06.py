from collections import namedtuple
import sys

import aoclib

# This solution is just plain brute force, better way wasn't immediately
# obvious

Point = namedtuple('Point', ['x', 'y'])
BoundingBox = namedtuple('BoundingBox', ['top', 'right', 'bottom', 'left'])


def manhattan_dist(p, q):
    return abs(p.x - q.x) + abs(p.y - q.y)


def bounding_box(points):
    if len(points) < 1:
        return None
    p0 = list(points)[0]
    top, right, bottom, left = p0.y, p0.x, p0.y, p0.x
    for p in points:
        if p.y < top:
            top = p.y
        if p.x > right:
            right = p.x
        if p.y > bottom:
            bottom = p.y
        if p.x < left:
            left = p.y
    return BoundingBox(top, right, bottom, left)


def closest_point(p, points):
    closest_dist = None
    closest_point = None
    for q in points:
        dist = manhattan_dist(q, p)
        if closest_dist is None or dist < closest_dist:
            closest_dist = dist
            closest_point = q
        elif dist == closest_dist:
            closest_point = None
    return closest_point


def unbounded_points(points):
    unbounded = set()
    def add_points_at_edge(xrange, yrange):
        for x in xrange:
            for y in yrange:
                closest = closest_point(Point(x, y), points)
                if closest is not None:
                    unbounded.add(closest)

    box = bounding_box(points)
    x_range = range(box.left, box.right + 1)
    y_range = range(box.top, box.bottom + 1)
    add_points_at_edge(x_range, [box.top])     # top
    add_points_at_edge([box.right], y_range)   # right
    add_points_at_edge(x_range, [box.bottom])  # bottom
    add_points_at_edge([box.left], y_range)    # left
    return unbounded


def find_areas(points):
    pointset = set(points)
    box = bounding_box(pointset)
    unbounded = unbounded_points(pointset)
    bounded = pointset.difference(unbounded)
    areas = {p: 0 for p in bounded}
    for x in range(box.left, box.right + 1):
        for y in range(box.top, box.bottom + 1):
            closest = closest_point(Point(x, y), pointset)
            if closest in areas:
                areas[closest] = areas[closest] + 1
    return areas


def read_points(f):

    def point_of_tuple(t):
        return Point(t[0], t[1])

    return [point_of_tuple(aoclib.read_point(line.strip())) for line in f]


def main():
    points = read_points(sys.stdin)
    areas = find_areas(points)
    answer = max(areas.values())
    print(answer)


if __name__ == '__main__':
    main()
