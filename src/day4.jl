module Day4

using DelimitedFiles

# Pair of 5x5 markers
mutable struct BingoBoard
    numbers::Matrix{Int}
    markers::Matrix{Bool}
end

struct BingoGame
    boards::Vector{BingoBoard}
    numbers::Vector{Int}
end

parseint(s) = parse(Int, s, base=10)

function parse_input(input::String)
    lines = split(input, "\n")
    # First line is list of numbers called
    numbers = map(parseint, split(lines[1], ","))
    boards = []
    # Followed by groups of six lines
    for i in 2:6:(length(lines)-6)
        board = zeros(5, 5)
        for k in 1:5
            board[k, :] .= map(parseint, split(lines[i+k]))
        end
        push!(boards, board)
    end

    bingoboards = map(boards) do b
        BingoBoard(b, zeros(Bool, 5, 5))
    end
    return BingoGame(bingoboards, numbers)
end

function play(game::BingoGame)
    won_boards = zeros(Bool, length(game.boards))
    first_winner_score = nothing
    for call in game.numbers
        for (i, board) in enumerate(game.boards)
            board.markers += board.numbers .== call

            colsums = sum(board.markers, dims=1)
            rowsums = sum(board.markers, dims=2)
            if max(maximum(colsums), maximum(rowsums)) == 5 && !won_boards[i]
                score = sum(board.numbers[board.markers .== 0]) * call
                if sum(won_boards) == 0
                    first_winner_score = score
                end
                won_boards[i] = 1
                if sum(won_boards) == length(game.boards)
                    return (first_winner_score, score)
                end
            end
        end
    end
end

test = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"""

test_game = parse_input(test)
first, last = play(test_game)
@assert first == 4512
@assert last == 1924

input = read("resources/day4_input.txt", String)
game = parse_input(input)
play(game) |> display

end
