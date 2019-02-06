open CCFun

module Coord = struct
    module S = struct
        type t = int * int

        let compare = CCPair.compare CCInt.compare CCInt.compare
    end

    include S

    module Set = CCSet.Make(S)
    module Map = CCMap.Make(S)

    module Let_syntax = Containers_let.Let.Make(CCParse)

    let parser = 
        let open CCParse in
        let%bind sx = char '(' *> chars_if is_num  in
        let%bind sy = char ',' *> chars_if is_num in
        char ')' *> return (int_of_string sx, int_of_string sy)

    let manhattan_distance (x1, y1) (x2, y2) =
        abs (x1 - x2) + abs (y1 - y2)
end


