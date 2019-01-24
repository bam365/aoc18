import sys
import functools

class FreqTable:
    def __init__(self, word):
        self.table = dict()
        for c in word:
            if c in self.table:
                self.table[c] = self.table[c] + 1
            else:
                self.table[c] = 1

    def has_char_with_count(self, n):
        for key, value in self.table.items():
            if value == n: return True
        return False

def checksum_words(words):
    freqs = [FreqTable(word.strip()) for word in words]
    def folder(acc, ft):
        two_count = ft.has_char_with_count(2)
        three_count = ft.has_char_with_count(3)
        return (two_count + acc[0], three_count + acc[1])
    counts = functools.reduce(folder, freqs, (0, 0))
    return counts[0] * counts[1]

def main():
    answer = checksum_words(sys.stdin)
    print(answer)

main()
