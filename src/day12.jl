module Day12

using ..Utils

const CaveSystem = Dict{String, Vector{String}}

function parse_cave_system(input::String)
    system = Dict{String, Vector{String}}()
    for line in split(input, "\n")
        if !isempty(line)
            mergeline!(system, line)
        end
    end
    system
end

function mergeline!(system::CaveSystem, line::AbstractString)
    a, b = split(line, "-")
    if a ∉ keys(system)
        push!(system, a => String[])
    end
    if b ∉ keys(system)
        push!(system, b => String[])
    end
    push!(system[a], b)
    push!(system[b], a)
    system
end

part1(system::CaveSystem) = paths_starting_at("start", system, ["start"]; used_double_visit=true)
part2(system::CaveSystem) = paths_starting_at("start", system, ["start"], used_double_visit=false)

function paths_starting_at(cave::String, system::CaveSystem, path_so_far::Vector{String}; used_double_visit=false)
    result = Vector{String}[]
    neighbors = system[cave]
    for neighbor in neighbors
        path = copy(path_so_far)
        push!(path, neighbor)
        if neighbor == "end"
            push!(result, path)
        elseif neighbor == "start"
            # No-op
        elseif isuppercase(neighbor[1]) # Don't worry about deduplicating big caves
            append!(result, paths_starting_at(neighbor, system, path, used_double_visit=used_double_visit))
        else
            # Lowercase cave
            visit_counts = count(s -> s == neighbor, path)

            if visit_counts == 1
                append!(result, paths_starting_at(neighbor, system, path, used_double_visit=used_double_visit))
            elseif !used_double_visit && visit_counts <= 2
                append!(result, paths_starting_at(neighbor, system, path, used_double_visit=true))
            end
        end
    end
    result
end

function run()
    test1 = """start-A
start-b
A-c
A-b
b-d
A-end
b-end
"""

    test2 = """dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"""

    test3 = """fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"""

    @assert test1 |> parse_cave_system |> part1 |> length == 10
    @assert test2 |> parse_cave_system |> part1 |> length == 19
    @assert test3 |> parse_cave_system |> part1 |> length == 226

    @assert test1 |> parse_cave_system |> part2 |> length == 36
    @assert test2 |> parse_cave_system |> part2 |> length == 103
    @assert test3 |> parse_cave_system |> part2 |> length == 3509

    input = read("resources/day12_input.txt", String)
    @show input |> parse_cave_system |> part1 |> length
    @show input |> parse_cave_system |> part2 |> length

end


function test_part2(test)
    part2_result = """
start,A,b,A,b,A,c,A,end
start,A,b,A,b,A,end
start,A,b,A,b,end
start,A,b,A,c,A,b,A,end
start,A,b,A,c,A,b,end
start,A,b,A,c,A,c,A,end
start,A,b,A,c,A,end
start,A,b,A,end
start,A,b,d,b,A,c,A,end
start,A,b,d,b,A,end
start,A,b,d,b,end
start,A,b,end
start,A,c,A,b,A,b,A,end
start,A,c,A,b,A,b,end
start,A,c,A,b,A,c,A,end
start,A,c,A,b,A,end
start,A,c,A,b,d,b,A,end
start,A,c,A,b,d,b,end
start,A,c,A,b,end
start,A,c,A,c,A,b,A,end
start,A,c,A,c,A,b,end
start,A,c,A,c,A,end
start,A,c,A,end
start,A,end
start,b,A,b,A,c,A,end
start,b,A,b,A,end
start,b,A,b,end
start,b,A,c,A,b,A,end
start,b,A,c,A,b,end
start,b,A,c,A,c,A,end
start,b,A,c,A,end
start,b,A,end
start,b,d,b,A,c,A,end
start,b,d,b,A,end
start,b,d,b,end
start,b,end"""

    part2_expected_paths = filter(!isempty, split(part2_result, "\n"))
    part2_actual_paths = [join(l, ",") for l in part2(parse_cave_system(test))]

    display(sort(part2_actual_paths))
    display(sort(part2_expected_paths))
end

end
