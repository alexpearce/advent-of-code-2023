import queue


def dijkstra(grid, start, ultra):
    visited = {}
    distances = queue.PriorityQueue()
    distances.put((0, (start, "east", 0)))
    while not distances.empty():
        distances, visited  = explore(grid, distances, visited, ultra)
    return visited


def explore(grid, distances, visited, ultra):
    if distances.empty():
        return visited
    (distance, node) = distances.get()
    if node in visited:
        return explore(grid, distances, visited, ultra)
    visited[node] = distance
    neighbours = get_neighbours(grid, node, ultra)
    for neighbour in neighbours:
        (coord, _, _) = neighbour
        if neighbour in visited:
            continue
        neighbour_distance = distance + grid[coord]
        distances.put((neighbour_distance, neighbour))
    return distances, visited


def get_neighbours(grid, node, ultra):
    (coord, dir, num_dir) = node
    neighbours = []
    if ultra:
        if num_dir < 10:
            neighbours.append(ahead_neighbour(coord, dir, num_dir))
        if num_dir >= 4:
            neighbours += perpendicular_neighbours(coord, dir)
    else:
        neighbours += perpendicular_neighbours(coord, dir)
        if num_dir < 3:
            neighbours.append(ahead_neighbour(coord, dir, num_dir))
    return [n for n in neighbours if n[0] in grid]


def perpendicular_neighbours(coord, dir):
    deltas = {
        "north": [((0, -1), "west"), ((0, 1), "east")],
        "south": [((0, -1), "west"), ((0, 1), "east")],
        "west": [((1, 0), "south"), ((-1, 0), "north")],
        "east": [((1, 0), "south"), ((-1, 0), "north")]
    }[dir]
    neighbours = []
    (x, y) = coord
    for ((dx, dy), neighbour_dir) in deltas:
        neighbours.append(((x + dx, y + dy), neighbour_dir, 1))
    return neighbours


def ahead_neighbour(coord, dir, num_dir):
    dx, dy = {
        "north": (-1, 0),
        "south": (1, 0),
        "west": (0, -1),
        "east": (0, 1)
    }[dir]
    neighbour = (coord[0] + dx, coord[1] + dy)
    return (neighbour, dir, num_dir + 1)


def part_one(grid):
    start = (0, 0)
    distances = dijkstra(grid, start, ultra=False)
    (corner_coord, _, _) = max(distances, key=lambda node: node[0])
    distance = min(d for (coord, _, num_dir), d in distances.items() if coord == corner_coord)
    return distance


def part_two(grid):
    start = (0, 0)
    distances = dijkstra(grid, start, ultra=True)
    (corner_coord, _, _) = max(distances, key=lambda node: node[0])
    distance = min(d for (coord, _, num_dir), d in distances.items() if coord == corner_coord and num_dir >= 4)
    return distance
    

def main():
    with open("17/input.txt") as f:
        lines = list(map(str.strip, f.readlines()))

    grid = {}
    for row, line in enumerate(lines):
        for col, char in enumerate(line):
            grid[(row, col)] = int(char)

    print(f"Part 1: {part_one(grid)}")
    print(f"Part 2: {part_two(grid)}")


if __name__ == "__main__":
    main()
