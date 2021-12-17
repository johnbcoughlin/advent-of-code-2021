module Day8

using ..Utils
using BenchmarkTools

function seven_permutation(n::Int)
    result = zeros(Int, 7)
    digits = Array{Int}(1:7)
    m = n
    for i in 7:-1:1
        k = digits[m % i + 1]
        result[i] = k
        m = m ÷ i
        filter!(x -> x!=k, digits)
    end
    result
end

function count_unique_digits(input)
    lines = filter(!isempty, split(input, "\n"))
    uniques = 0
    for line in lines
        outputs = split(line, " | ")[2] |> split
        for output in outputs
            if length(output) ∈ [2, 3, 4, 7]
                uniques += 1
            end
        end
    end
    uniques
end

function decode(input)
    for line in lines
        decodeline(input)
    end
end

initial_possibilities() = begin
    p = Dict()
    for i in 1:7
        push!(p, i=>["a", "b", "c", "d", "e", "f", "g"])
    end
    p
end

toints(symbol) = [findfirst(ch, "abcdefg") for ch in symbol]
fromints(ints) = "abcdefg"[ints]

Base.:-(s1::Union{AbstractString, Vector{Char}},
        s2::Union{AbstractString, Vector{Char}}) = setdiff(s1, s2)

function decodeline(line)
    code = split(line, " | ")[1] |> split
    code = sort(code, by=length)
    sols = Dict()

    all = "abcdefg"
    # [1 2 3 4 5 6 7 8 9 10]
    # [1 7 4 2 3 5 6 9 0 8]
    # [0 1 2 3 4 5 6 7 8 9]
    # The top row is included in "7" but not "1"
    sols['a'] = (code[2] - code[1]) |> only
    # Bars not contained in 6, 9, or 0.
    # Should be c, d, e.
    complement_690 = all - (code[7] ∩ code[8] ∩ code[9])
    sols['c'] = (code[1] ∩ complement_690) |> only
    sols['f'] = code[1] - [sols['c']] |> only
    sols['d'] = complement_690 ∩ (code[3] - code[1]) |> only
    sols['e'] = (complement_690 - [sols['c'], sols['d']]) |> only
    # Bar b is contained in 4 and in the complement of (2, 3, 5),
    sols['b'] = code[3] - [sols['c'], sols['d'], sols['f']] |> only
    sols['g'] = all - [sols[ch] for ch in "abcdef"] |> only

    coding = Dict()

    for (from, to) in sols
        push!(coding, to => from)
    end
    coding
end

function decode_digit(time::AbstractString, coding::Dict)
    bars = [coding[ch] for ch in time]
    if length(bars) == 2
        return 1
    elseif length(bars) == 3
        return 7
    elseif length(bars) == 4
        return 4
    elseif length(bars) == 7
        return 8
    elseif length(bars) == 5
        if isempty("acdeg" - bars)
            return 2
        elseif isempty("abdfg" - bars)
            return 5
        elseif isempty("acdfg" - bars)
            return 3
        end
    elseif length(bars) == 6
        if isempty("abdefg" - bars)
            return 6
        elseif isempty("abcdfg" - bars)
            return 9
        elseif isempty("abcefg" - bars)
            return 0
        end
    else
        return 8
    end
end

function decode_time(time::AbstractString, coding::Dict)
    digits = split(time)
    time = 0
    for digit in digits
        d = decode_digit(digit, coding)
        time *= 10
        time += d
    end
    time
end

function add_up_times(input::String)
    sum = 0
    for line in filter(!isempty, split(input, "\n"))
        coding = decodeline(line)
        time = split(line, " | ")[2]
        sum += decode_time(time, coding)
    end
    sum
end

test = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"""

function run()
    @assert count_unique_digits(test) == 26

    input = read("resources/day8_input.txt", String)
    count_unique_digits(input) |> display

    @assert add_up_times(test) == 61229
    add_up_times(input) |> display

    @btime add_up_times($input)
end


end
