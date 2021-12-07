module Day7

using ..Utils
using FFTW


pad_histogram(histogram) = begin
    len = length(histogram)
    # Make the length the next power of two which is at least 3*len
    padded_len = 2^(floor(log2(3*len)) + 1) |> Int
    padded = vcat(zeros(len), histogram, zeros(padded_len - 2len))
end

convolution_with(histogram, f) = begin
    len = length(histogram)
    padded = pad_histogram(histogram)
    padded_len = length(padded)

    abs_array = (Array(1:padded_len) .- padded_len / 2) .|> f

    conv = irfft(rfft(abs_array) .* rfft(padded), padded_len) |> fftshift
    conv = conv[len:2len-1]
    conv
end

function best_position(input, cost)
    histogram = comma_separated_to_histogram(input)
    conv = convolution_with(histogram, cost)
    pos = argmin(conv) - 1
    best = minimum(conv)
    return (pos, Int(round(best)))
end

part2_cost(n) = Int(round(abs(n) * (abs(n)+1) / 2))

function run()
    test = "16,1,2,0,4,2,7,1,2,14"
    @assert best_position(test, abs) == (2, 37)

    input = read("resources/day7_input.txt", String)
    @time @show best_position(input, abs)

    @assert best_position(test, part2_cost) == (5, 168)
    @time @show best_position(input, part2_cost)
end



end
