import sys

import aoclib


class MarbleRing:

    def __init__(self):
        self.ring = []

    def _rotate(self, pop_idx, ins_idx):
        if len(self.ring) > 0:
            item = self.ring.pop(pop_idx)
            self.ring.insert(ins_idx, item)

    def _rotate_clockwise(self): return self._rotate(0, len(self.ring))

    def _rotate_counterclockwise(self): return self._rotate(-1, 0)

    def add(self, num: int) -> int:
        ret = 0
        if num % 23 == 0 and num > 0:
            ret += num
            for _ in range(7):
                self._rotate_counterclockwise()
            ret += self.ring.pop(0)
        else:
            self._rotate_clockwise()
            self._rotate_clockwise()
            self.ring.insert(0, num)
        return ret


def play_game(player_count: int, marble_count: int) -> int:
    """ returns the highest score """
    ring = MarbleRing()
    scores = [0 for _ in range(player_count)]
    for marble in range(marble_count + 1):
        player = marble % player_count
        scores[player] += ring.add(marble)
    return max(scores)


def main():
    nums = aoclib.int_stream(sys.stdin)
    player_count = next(nums)
    marble_count = next(nums)
    answer = play_game(player_count, marble_count)
    print(answer)


main()


def test_play_game():
    assert play_game(10, 1618) == 8317
    assert play_game(13, 7999) == 146373
    assert play_game(17, 1104) == 2764
    assert play_game(21, 6111) == 54718
    assert play_game(30, 5807) == 37305
