module Day11

using SparseArrays
using ..Utils

neighbors_matrix(n, m) = begin
    bidiag(k) = spdiagm(-1 => ones(Bool, k-1), 1 => ones(Bool, k-1))
    tridiag(k) = spdiagm(-1 => ones(Bool, k-1), 0 => ones(Bool, k), 1 => ones(Bool, k-1))

    kron(bidiag(m), tridiag(n)) .| kron(tridiag(m), bidiag(n))
end

function step!(octopuses::Matrix{Int8})
    n, m = size(octopuses)
    octopuses = vec(octopuses)
    neighbors = neighbors_matrix(n, m)

    # Increase each by 1
    octopuses .+= 1

    # Any which are above 9
    already_flashed = spzeros(Bool, length(octopuses))

    flashing = sparse(octopuses .> 9)
    already_flashed .|= flashing
    while any(flashing)
        octopuses .+= neighbors * flashing
        flashing = sparse(octopuses .> 9) .⊻ already_flashed
        already_flashed .|= flashing
    end
    octopuses[already_flashed] .= 0
    return sum(already_flashed)
end

function part1(octopuses)
    sum = 0
    for i in 1:100
        sum += step!(octopuses)
    end
    return sum
end

function part2(octopuses)
    i = 0
    while true
        i += 1
        count = step!(octopuses)
        if count == length(octopuses)
            return i
        end
    end
end

function run()
    test = """5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"""

    test_octopuses = parse_array(test)
    @assert part1(test_octopuses) == 1656
    @assert part2(parse_array(test)) == 195

    input = """4764745784
4643457176
8322628477
7617152546
6137518165
1556723176
2187861886
2553422625
4817584638
3754285662"""

    octopuses = parse_array(input)
    @show part1(octopuses)
    octopuses = parse_array(input)
    @show part2(octopuses)
end

end
