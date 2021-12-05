module Day5

parseint(s) = parse(Int, s, base=10)

point_pairs(input::String) = begin
    lines = split(input, "\n")
    result = []
    for line in lines
        if isempty(line)
            continue
        end
        first, second = split(line, " -> ")
        a1, b1 = map(parseint, split(first, ","))
        a2, b2 = map(parseint, split(second, ","))
        push!(result, ((a1, b1), (a2, b2)))
    end
    result
end

maxima(point_pairs::Vector) = begin
    x_max = y_max = -1
    for pair in point_pairs
        first, second = pair
        a1, b1 = first
        a2, b2 = second
        x_max = max(x_max, a1, a2)
        y_max = max(y_max, b1, b2)
    end
    return (x_max, y_max)
end

score_point_pair!(array::Matrix{Int}, point_pair; orthogonal_only=true) = begin
    first, second = point_pair
    x1, y1 = first
    x2, y2 = second
    len = max(abs(x2 - x1), abs(y2 - y1))
    xinc = (x2 - x1) ÷ len
    yinc = (y2 - y1) ÷ len

    if orthogonal_only && (xinc != 0 && yinc != 0)
        return
    end

    x = x1 + 1
    y = y1 + 1
    for i in 0:len
        array[y, x] += 1
        x += xinc
        y += yinc
    end
end

dopart(input; orthogonal_only) = begin
    pairs = point_pairs(input)
    cols, rows = maxima(pairs)
    A = zeros(Int, cols+2, rows+2)
    for pair in pairs
        score_point_pair!(A, pair, orthogonal_only=orthogonal_only)
    end
    return sum(A .≥ 2)
end

part1(input) = begin
    dopart(input, orthogonal_only=true)
end

part2(input) = begin
    dopart(input, orthogonal_only=false)
end

test = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"""

@assert part1(test) == 5
@assert part2(test) == 12
input = read("resources/day5_input.txt", String)
part1(input) |> display
part2(input) |> display

end
