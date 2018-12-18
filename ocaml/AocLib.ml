open CCFun
let read_ints =
    CCIO.read_lines_l
    %> List.map int_of_string

module IntOrdered = struct
    type t = int
    let compare = ( - )
end

module IntSet = CCSet.Make(IntOrdered)
