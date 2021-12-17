module Utils

export comma_separated_to_histogram, parse_array

# Creates a histogram of the counts, one-indexed.
comma_separated_to_histogram(str::String) = begin
    ints = [parse(Int, a) for a in split(str, ",")]
    max = maximum(ints)
    foldl(ints, init=zeros(Int, max+1)) do acc, age
        acc[age+1] += 1
        acc
    end
end

# Parse a matrix
parse_array(input) = begin
    array = nothing
    for row in filter(!isempty, split(input, "\n"))
        numbers = [parse(Int8, digit) for digit in split(row, "")]
        if isnothing(array)
            array = zeros(Int8, length(numbers), 0)
        end
        array = hcat(array, numbers)
    end
    array
end

end
