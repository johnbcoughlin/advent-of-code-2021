module Day10

function scores(line)
    stack = Char[]
    for ch ∈ line
        if ch ∈ "([{<"
            push!(stack, ch)
        else
            match = pop!(stack)
            if abs(Int(ch) - Int(match)) > 2
                corruption_score = ch == ')' ? 3 :
                    ch == ']' ? 57 :
                    ch == '}' ? 1197 :
                    25137
                return (corruption_score, 0)
            end
        end
    end
    # We came to the end without finding any corrupted input.
    # Now calculate the autocompletion score.
    completion_score = 0
    while !isempty(stack)
        ch = pop!(stack)
        increment = ch == '(' ? 1 :
            ch == '[' ? 2 :
            ch == '{' ? 3 :
            4
        completion_score *= 5
        completion_score += increment
    end
    return (0, completion_score)
end

function sum_scores(input)
    corruption_score = 0
    completion_scores = []
    for line in filter(!isempty, split(input, "\n"))
        corruption, completion = scores(line)
        corruption_score += corruption
        if completion != 0
            push!(completion_scores, completion)
        end
    end
    sort!(completion_scores)
    (corruption_score, completion_scores[(length(completion_scores) + 1) ÷ 2])
end

function run()
    test = """[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"""

    @assert sum_scores(test) == (26397, 288957)

    input = read("resources/day10_input.txt", String)
    display(sum_scores(input))
end


end
