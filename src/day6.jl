module Day6

using SparseArrays

M = spdiagm(1 => ones(Int32, 8))
M[7, 1] = M[9, 1] = 1

test = "3,4,3,1,2"

sim(input::String, day::Int) = begin
    pops = foldl(split(input, ","), init=zeros(Int, 9)) do acc, age
        acc[parse(Int, age)+1] += 1
        acc
    end
    sum(M^day * pops)
end

@assert sim(test, 80) == 5934
@assert sim(test, 256) == 26984457539

input = read("resources/day6_input.txt", String)
sim(input, 80) |> display
sim(input, 256) |> display

@time M^256

function do_it_really_really_fast()
    M2 = M^2
    M4 = M2^2
    M8 = M4^2
    M16 = M8^2
    M32 = Array(M16^2)
    M64 = M32^2
    M128 = M64^2
    M256 = M128^2
end

end
