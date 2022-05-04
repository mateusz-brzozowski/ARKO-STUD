from math import atan, pi, pow

CORDIC_1OVERK = 0.6072529350088812561694467525049282631123908521500897724
F230_ONE = 0x8000_0000


def to_f230(n):
    return int(n * F230_ONE)


def from_f230(n):
    return n / F230_ONE


def get_f230_atantab(target_len):
    tab = []
    for i in range(target_len):
        tab.append(to_f230(atan(2 ** -i)/pi))
    return tab


if __name__ == "__main__":
    t = get_f230_atantab(32)

    for i in t:
        print(f"0x{i:0>8X}", end=",\n")
