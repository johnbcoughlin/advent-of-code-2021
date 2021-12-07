module Utils

export comma_separated_to_histogram

# Creates a histogram of the counts, one-indexed.
comma_separated_to_histogram(str::String) = begin
    ints = [parse(Int, a) for a in split(str, ",")]
    max = maximum(ints)
    foldl(ints, init=zeros(Int, max+1)) do acc, age
        acc[age+1] += 1
        acc
    end
end

end
