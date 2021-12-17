module Day13

using SparseArrays

struct Problem
    holes::Vector{NTuple{2, Int}}
    folds::Vector{Tuple{NTuple{2, Int}, Int}}
end

function parse_problem(input)
    holes_str, instructions = split(input, "\n\n")
    holes = NTuple{2, Int}[]
    for line in split(holes_str, "\n")
        a, b = split(line, ",")
        push!(holes, (parse(Int, a), parse(Int, b)))
    end

    folds_str = split(instructions, "\n")
    folds = Tuple{NTuple{2, Int}, Int}[]
    for line in filter(!isempty, folds_str)
        s = last(split(line, " "))
        p, q = split(s, "=")
        q = parse(Int, q)
        push!(folds, p == "x" ? ((q, 0), 1) : ((0, q), 2))
    end

    return Problem(holes, folds)
end

apply(fold, hole) = begin
    h = hole .- fold[1]
    if fold[2] == 1
        (fold[1][1] - abs(h[1]), h[2])
    else
        (h[1], fold[1][2] - abs(h[2]))
    end
end

function part1(problem)
    fold = problem.folds[1]
    folded = map(problem.holes) do tuple
        apply(fold, tuple)
    end
    return length(unique(folded))
end

function part2(problem)
    holes = problem.holes
    for fold in problem.folds
        holes = map(holes) do tuple
            apply(fold, tuple)
        end |> unique
    end

    xmax = maximum(hole[1] for hole in holes)
    ymax = maximum(hole[2] for hole in holes)
    xmin = minimum(hole[1] for hole in holes)
    ymin = minimum(hole[2] for hole in holes)

    M = spzeros(Int, ymax - ymin + 1, xmax - xmin + 1)
    for hole in holes
        x, y = hole
        M[y - ymin + 1, x - xmin + 1] = 1
    end
    display(M)
end

function run()
    test = """6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"""

    # @assert test |> parse_problem |> part1 == 17

    input = read("resources/day13_input.txt", String)

    input |> parse_problem |> part1 |> display

    part2(parse_problem(test))
    part2(parse_problem(input))

    # display(parse_problem(input))
end


end
