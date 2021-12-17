module Day9

using BenchmarkTools
using LoopVectorization
using ..Utils

function find_risk_level(array)
    n, m = size(array)
    risk_level = 0
    for j in 1:m
        running_uphill = false
        i = 1
        while i <= n
            while i < n && array[i, j] >= array[i+1, j] # running downhill or level, keep going
                i += 1
            end

            # Either we hit a rise or the end of the row.
            # Check if the other directions are satisfied.
            if (j == 1 || array[i, j] < array[i, j-1]) && (j == m || array[i, j] < array[i, j+1])
                risk_level += array[i, j] + 1
            end

            i += 1

            while 1 < i <= n && array[i-1, j] <= array[i, j] # running uphill, keep going
                i += 1
            end
        end
    end

    risk_level
end

function find_basin_sizes_bfs(array)
    n, m = size(array)
    basin_sizes = []
    # Queue of unassigned index pairs
    unassigned = Base.Iterators.product(1:n, 1:m) |> Set
    while !isempty(unassigned)
        next = pop!(unassigned)
        # If it's a 9, then continue to the next.
        k = array[next...]
        if k == 9
            continue
        else
            # Otherwise, it's the start of a new basin
            current_basin_queue = [next]
            current_basin_size = 1
            current_basin = Set(current_basin_queue)
            while !isempty(current_basin_queue)
                current_idx = pop!(current_basin_queue)
                i, j = current_idx
                for neighbor in [(i+1, j), (i-1, j), (i, j-1), (i, j+1)]
                    if neighbor ∈ current_basin
                        continue
                    end
                    k, l = neighbor
                    # Check the neighbor is inbounds
                    if !(1 <= k <= n && 1 <= l <= m)
                        continue
                    end
                    if array[k, l] == 9
                        continue
                    else
                        delete!(unassigned, neighbor)
                        push!(current_basin, neighbor)
                        push!(current_basin_queue, neighbor)
                        current_basin_size += 1
                    end
                end
            end
            push!(basin_sizes, current_basin_size)
        end
    end
    basin_sizes
end

function find_basins_coalesce(array)
    n, m = size(array)
    # Start with an array of tuples of coordinates
    basin_roots = Base.Iterators.product(1:n, 1:m) |> collect

    # Collect each row together
    contiguous_ranges = []
    for j in 1:m
        col_ranges = []
        range_start = 1
        for i in 1:n
            k = array[i, j]
            if k == 9
                if range_start < i
                    push!(col_ranges, range_start:i-1)
                end
                range_start = i+1
                basin_roots[i, j] = (0, 0)
            elseif i > 1 && array[i-1, j] != 9
                basin_roots[i, j] = basin_roots[i-1, j]
            end
        end
        if range_start <= n
            push!(col_ranges, range_start:n)
        end
        push!(contiguous_ranges, col_ranges)
    end

    # display(basin_roots)
    # display(contiguous_ranges)
end

function run()
    test = """2199943210
3987894921
9856789892
8767896789
9899965678
""";
    test_array = parse_array(test)
    @assert find_risk_level(test_array) == 15

    input = read("resources/day9_input.txt", String)
    input_array = parse_array(input)
    @show find_risk_level(input_array)

    top3_prod(a) = sort(a)[end-2:end] |> prod
    @assert find_basin_sizes_bfs(test_array) |> top3_prod == 1134
    # @benchmark (find_basin_sizes_bfs($input_array) |> $top3_prod) samples=100
    @time find_basin_sizes_bfs(input_array) |> top3_prod

    @time find_basins_coalesce(input_array)
end

end
