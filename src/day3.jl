module Day3

using DelimitedFiles

data_as_matrix(strings, bitcount) = begin
    m = zeros(Int, (length(strings), bitcount))
    for (row, string) in enumerate(strings)
        for bit in 1:bitcount
            b = parse(Int, string[bit])
            m[row, bit] = b
        end
    end
    m
end

bit_ratings(m) = begin
    hist = sum(m, dims=1) |> vec
    @assert size(hist) == (size(m, 2),)

    avgs = hist ./ size(m, 1)
    most_common = Int.(round.(avgs, RoundNearestTiesUp))
    least_common = 1 .- most_common
    (most_common, least_common)
end

rates_product(strings, bitcount) = begin
    m = data_as_matrix(strings, bitcount)

    γ_bits, ϵ_bits = bit_ratings(m)

    γ = parse(Int, join(γ_bits), base=2)
    ϵ = parse(Int, join(ϵ_bits), base=2)

    γ * ϵ
end

life_support_rating(strings, bitcount) = begin
    m = data_as_matrix(strings, bitcount)
    oxygen_candidates = co2_candidates = m

    for i in 1:bitcount
        if size(oxygen_candidates, 1) > 1
            most, _ = bit_ratings(oxygen_candidates)
            oxygen_mask = view(oxygen_candidates, :, i) .== most[i]
            oxygen_candidates = oxygen_candidates[oxygen_mask, :]
        end

        if size(co2_candidates, 1) > 1
            _, least = bit_ratings(co2_candidates)
            co2_mask = view(co2_candidates, :, i) .== least[i]
            co2_candidates = co2_candidates[co2_mask, :]
        end
    end

    oxygen_rating = parse(Int, join(oxygen_candidates[1, :]), base=2)
    co2_rating = parse(Int, join(co2_candidates[1, :]), base=2)

    oxygen_rating * co2_rating
end

test = ["00100"
        "11110"
        "10110"
        "10111"
        "10101"
        "01111"
        "00111"
        "11100"
        "10000"
        "11001"
        "00010"
        "01010"];

@assert rates_product(test, 5) == 198

@assert life_support_rating(test, 5) == 230

input = readdlm("resources/day3_input.txt", '\t', String, '\n') |> vec;

display(rates_product(input, 12))
display(life_support_rating(input, 12))

end
