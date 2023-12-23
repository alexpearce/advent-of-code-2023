NULL_BRICK = ([0, 0, 0], [0, 0, 0])


def parse_brick(line):
    l, r = line.split("~")
    l = list(map(int, l.split(",")))
    r = list(map(int, r.split(",")))
    if r[-1] < l[-1]:
        l, r = r, l
    return l, r


def sort_by_z(bricks):
    return sorted(bricks, key=lambda brick: brick[0][-1])


def footprint(brick):
    coords = []
    for x in range(brick[0][0], brick[1][0] + 1):
        for y in range(brick[0][1], brick[1][1] + 1):
            coords.append((x, y))
    return coords


def drop_brick(brick, z):
    brick_height = brick[1][-1] - brick[0][-1]
    return ([brick[0][0], brick[0][1], z], [brick[1][0], brick[1][1], z + brick_height])


def settle(bricks):
    height_map = {}
    settled = []
    for brick in bricks:
        coords = footprint(brick)
        height = 1 + max(height_map.get(coord, 0) for coord in coords)
        dropped = drop_brick(brick, height)
        for coord in coords:
            height_map[coord] = height + (dropped[1][-1] - dropped[0][-1])
        settled.append(dropped)
    return sort_by_z(settled)


with open("22/input.txt") as f:
    lines = list(map(str.strip, f.readlines()))
bricks = [parse_brick(line) for line in lines]
bricks = sort_by_z(bricks)
bricks = settle(bricks)
can_disintegrate = 0
for idx in range(0, len(bricks)):
    without = bricks[:idx] + bricks[idx + 1:]
    if settle(without) == without:
        can_disintegrate += 1
print(can_disintegrate)
