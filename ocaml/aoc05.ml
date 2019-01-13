let will_react a b = a != b && (CCChar.lowercase_ascii a) = (CCChar.lowercase_ascii b)

let react_polymer = 
    let rec loop acc xs = 
        match (acc, xs) with
        | (a::as_, x::xs') ->
            let acc' = if will_react a x then as_ else x::acc in
            loop acc' xs'
        | ([], x::xs') ->
          loop [x] xs'
        | (_, []) -> List.rev acc
    in loop []
            
let () =
    CCIO.read_all stdin
    |> CCString.trim
    |> CCString.to_list
    |> react_polymer
    |> CCList.length
    |> AocLib.print_result
