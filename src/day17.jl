module Day17

struct TargetArea
    x::UnitRange{Int}
    y::UnitRange{Int}
end

function parse_target(input::String)
    input = split(input, ": ")[2]
    xpart, ypart = split(input, ", ")
    xpart = split(split(xpart, "=")[2], "..")
    ypart = split(split(ypart, "=")[2], "..")

    x = parse(Int, xpart[1]):parse(Int, xpart[2])
    y = parse(Int, ypart[1]):parse(Int, ypart[2])

    TargetArea(x, y)
end

function part1(target::TargetArea)
    S = abs(target.y[1])
    Int((S - 1) * S / 2)
end

function match_x_in_steps(range::UnitRange{Int}, n)
    # for 2 steps,
    # l <= v + v-1 <= r
    # for 3 steps,
    # l <= v + v-1 + v-2 <= r --> l+3 <= 3v <= r+3 --> l/3+1 <= v <= r/3+1
    l = range[1]
    r = range[end]
    triangle = n * (n-1) / 2
    lower = (l+triangle)/n |> ceil |> Int
    upper = (r + triangle)/n |> floor |> Int
    return lower:upper
end

function match_y_in_steps(range::UnitRange{Int}, n)
    # the problem is symmetric, so only need to consider negative vy.
    # for 1 step,
    # t <= v <= b
    # for 2 steps,
    # t <= v + v+1 <= b
    # for 3 steps,
    # t <= v + v+1 + v+2 <= b
    # ...
    # t-tri <= nv <= b-tri
    t = range[end] |> abs
    b = range[1] |> abs
    triangle = n * (n-1) / 2
    lower = (t - triangle) / n |> ceil |> Int
    upper = (b - triangle) / n |> floor |> Int
    return -(lower:upper)
end

function match(target::TargetArea)
    vxs = Dict()
    stalled_out_vxs = Int[]
    n = 1
    while n*(n+1)/2 <= target.x[end]
        matches = match_x_in_steps(target.x, n)
        push!(vxs, n => Array(matches))
        # For all of the x velocities which arrive in vx steps,
        # they are "stalled out".
        if n in matches
            push!(stalled_out_vxs, n)
        end
        n += 1
    end

    vys = Dict()
    n = 1
    while n*(n+1)/2 <= abs(target.y[1])
        push!(vys, n => Array(match_y_in_steps(target.y, n)))
        n += 1
    end
    i = 0
    k = 0
    for (n, vy) in vys
        vy = vy[vy .< 0]
        parabola_steps = 2abs.(vy) .- 1
        original_vy = -1 .- vy
        for (pn, vy) in zip(parabola_steps, original_vy)
            if (pn+n) ∈ keys(vys)
                push!(vys[pn+n], vy)
            else
                push!(vys, (pn+n) => [vy])
            end
        end
        i += 1
    end

    velocities = Set()
    # Need to find a solution for each vy
    for (n, vy) in vys
        if n ∈ keys(vxs)
            n_step_velocities = tuple.(vxs[n], Array(vys[n])') |> collect
            union!(velocities, vec(n_step_velocities))
        else
            stalled_out_matches = stalled_out_vxs[stalled_out_vxs .<= n]
            vs = tuple.(stalled_out_vxs, Array(vys[n])') |> collect
            union!(velocities, vs)
        end
    end
    velocities
end


function run()
    test = "target area: x=20..30, y=-10..-5"
    testarea = parse_target(test)

    @assert part1(testarea) == 45
    @assert length(match(testarea)) == 112

    input = "target area: x=155..182, y=-117..-67"
    target = parse_target(input)
    display(part1(target))
    display(length(match(target)))
end

function test_part2()
    expected = """23,-10  25,-9   27,-5   29,-6   22,-6   21,-7   9,0     27,-7   24,-5
25,-7   26,-6   25,-5   6,8     11,-2   20,-5   29,-10  6,3     28,-7
8,0     30,-6   29,-8   20,-10  6,7     6,4     6,1     14,-4   21,-6
26,-10  7,-1    7,7     8,-1    21,-9   6,2     20,-7   30,-10  14,-3
20,-8   13,-2   7,3     28,-8   29,-9   15,-3   22,-5   26,-8   25,-8
25,-6   15,-4   9,-2    15,-2   12,-2   28,-9   12,-3   24,-6   23,-7
25,-10  7,8     11,-3   26,-7   7,1     23,-9   6,0     22,-10  27,-6
8,1     22,-8   13,-4   7,6     28,-6   11,-4   12,-4   26,-9   7,4
24,-10  23,-8   30,-8   7,0     9,-1    10,-1   26,-5   22,-9   6,5
7,5     23,-6   28,-10  10,-2   11,-1   20,-9   14,-2   29,-7   13,-3
23,-5   24,-8   27,-9   30,-7   28,-5   21,-10  7,9     6,6     21,-5
27,-10  7,2     30,-9   21,-8   22,-7   24,-9   20,-6   6,9     29,-5
8,-2    27,-8   30,-5   24,-7"""
    expected = split(expected) |> Set

    test = "target area: x=20..30, y=-10..-5"
    testarea = parse_target(test)
    velocities = match(testarea)
    actual = [join(v, ",") for v in velocities] |> Set

    setdiff(actual, expected) |> display
    setdiff(expected, actual) |> display
end

end
