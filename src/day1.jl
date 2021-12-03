module Day1

using DelimitedFiles

count(vals) = sum(diff(vals) .> 0)

windowed_count(vals; k=3) = sum(diff(window_sums(vals, k=k)) .> 0)

test = [199
        200
        208
        210
        200
        207
        240
        269
        260
        263];

@assert count(test) == 7
@assert windowed_count(test) == 7

input = readdlm("resources/day1_input", '\t', Int, '\n') |> vec;

display(count(input))
display(windowed_count(input))


end
