open CCFun

module CharMap = CCMap.Make(CCChar)

module FreqTable = struct
    type t = int CharMap.t

    let of_string = 
        let folder t k =
            let inc_map v = let v' = CCOpt.get_or ~default:0 v in Some(v' + 1)
            in CharMap.update k inc_map t
        in
        CCString.to_list
        %> List.fold_left folder CharMap.empty

    let has_char_with_count n =
        CharMap.exists (fun _ c -> c = n)
end

let checksum = 
    let folder (two_check, three_check) freq =
        let inc_if_count count n = 
            if FreqTable.has_char_with_count count freq then n + 1 else n
        in
        (inc_if_count 2 two_check, inc_if_count 3 three_check)
    in
    List.fold_left folder (0, 0)
    %> fun (two_check, three_check) -> two_check * three_check

let () =
    CCIO.read_lines_l stdin
    |> List.map FreqTable.of_string
    |> checksum
    |> AocLib.print_result
