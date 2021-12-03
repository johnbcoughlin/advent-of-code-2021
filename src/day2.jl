module Day2

using DelimitedFiles

mutable struct Position
    x::Int
    depth::Int
    aim::Int
end

update_aiming!(position, command) = begin
    parts = split(command)
    dir = parts[1]
    n = parse(Int, parts[2])
    if dir == "forward"
        position.x += n
        position.depth += n * position.aim
    elseif dir == "down"
        position.aim += n
    elseif dir == "up"
        position.aim -= n
    end
end

update!(position, command) = begin
    parts = split(command)
    dir = parts[1]
    n = parse(Int, parts[2])
    if dir == "forward"
        position.x += n
    elseif dir == "down"
        position.depth += n
    elseif dir == "up"
        position.depth -= n
    end
end

run_part1(commands) = begin
    pos = Position(0, 0, 0)
    for command in commands
        update!(pos, command)
    end
    @show pos.x
    @show pos.depth
    return pos.x * pos.depth
end

run_part2(commands) = begin
    pos = Position(0, 0, 0)
    for command in commands
        update_aiming!(pos, command)
    end
    return pos.x * pos.depth
end

test = ["forward 5"
        "down 5"
        "forward 8"
        "up 3"
        "down 8"
        "forward 2"];

@assert run_part1(test) == 150;
@assert run_part2(test) == 900;

input = readdlm("resources/day2_input.txt", '\t', String, '\n') |> vec;

@show (input |> run_part1)
@show (input |> run_part2)

end
