module Day14

using SparseArrays

struct System
    transitions::AbstractMatrix{Int}
    letter_counts::AbstractMatrix{Int}
    pairs::AbstractVector{Int}
    V::Vector{String}
    letters::Vector{Char}
    first_and_last::Vector{Int}
end

function input_to_system(input)::System
    start, transitions = split(input, "\n\n")
    dict = Dict()
    for line in filter(!isempty, split(transitions, "\n"))
        key, val = split(line, " -> ")
        pairs = ["$(key[1])$(val)", "$(val)$(key[2])"]
        push!(dict, key=>pairs)
    end
    N = length(dict)
    V = sort(collect(keys(dict)))

    M = spzeros(Int, N, N)
    for (key, pairs) in dict
        v1, v2 = pairs
        j = searchsortedfirst(V, key)
        i1 = searchsortedfirst(V, v1)
        i2 = searchsortedfirst(V, v2)
        M[i1, j] = M[i2, j] = 1
    end

    start_pairs = [start[i:i+1] for i in 1:length(start)-1]
    locs = [searchsortedfirst(V, pair) for pair in start_pairs]
    v = spzeros(N)
    for loc in locs
        v[loc] += 1
    end

    # Matrix mapping pairs to letter counts
    letters = sort(unique(join(V, "")))
    c = length(letters)
    S = zeros(c, N)
    for (j, pair) in enumerate(V)
        for letter in pair
            i = searchsortedfirst(letters, letter)
            S[i, j] += 1
        end
    end

    first_and_last = zeros(c)
    first_and_last[searchsortedfirst(letters, start[1])] = 1
    first_and_last[searchsortedfirst(letters, start[end])] = 1

    return System(M, S, v, V, letters, first_and_last)
end

function advance(sys::System; gen::Int)
    transition = sys.transitions^gen
    undeduped_counts = sys.letter_counts * transition * sys.pairs
    counts = ((undeduped_counts - sys.first_and_last) ./ 2 .|> Int) + sys.first_and_last
    counts
end

function run()
    test = """NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"""

    testsystem = input_to_system(test)
    testcounts = advance(testsystem, gen=10)
    @assert maximum(testcounts) - minimum(testcounts) == 1588

    testsystem = input_to_system(test)
    testcounts = advance(testsystem, gen=40)
    @assert maximum(testcounts) - minimum(testcounts) == 2188189693529

    input = read("resources/day14_input.txt", String)
    system = input_to_system(input)
    counts = advance(system, gen=10)
    maximum(counts) - minimum(counts) |> display

    system = input_to_system(input)
    counts = advance(system, gen=40)
    maximum(counts) - minimum(counts) |> display
end


end
