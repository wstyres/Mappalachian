coordinates = []
while True:
    coordinate = input()
    if coordinate:
        coordinates.append(coordinate)
    else:
        break

coordinates = [c.split(", ") for c in coordinates]

output = []
for c in coordinates:
    c.reverse()
    joined = "[" + ", ".join(c) + "],"
    print(joined)