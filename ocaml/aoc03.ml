open CCFun

module CountRect = struct
    type t = int AocLib.Array2D.t
    
    let create = AocLib.Array2D.create

    let blit' xoff yoff src dest = 
        AocLib.Array2D.merge_unsafe ( + ) xoff yoff ~src ~dest
    
    let squares_with fn t =
        let open AocLib.Array2D in
        Array.fold_left (fun acc v -> if fn v then acc + 1 else acc) 0 t.arry
end

module RectSpec = struct
    type t = 
        { id : string
        ; x : int
        ; y : int
        ; width : int
        ; height : int
        }

    let regex = 
        "^#\\([0-9]*\\) @ \\([0-9]*\\),\\([0-9]*\\): \\([0-9]*\\)x\\([0-9]*\\)" 
        |> Str.regexp

    let parse_exn s =
        let int_group n = Str.matched_group n s |> int_of_string in
        match Str.string_match regex s 0 with
        | false -> failwith "Malformed rect spec"
        | true -> 
            { id = Str.matched_group 1 s
            ; x = int_group 2
            ; y = int_group 3
            ; width = int_group 4
            ; height = int_group 5
            }
end

let () = 
    let fabric = CountRect.create 1000 1000 0 
    in CCIO.read_lines_l stdin
    |> List.map RectSpec.parse_exn
    |> List.iter begin fun spec ->
        let open RectSpec in
        let rect = CountRect.create spec.width spec.height 1 in
        CountRect.blit' spec.x spec.y rect fabric
    end;
    CountRect.squares_with (fun n -> n > 1) fabric
    |> AocLib.print_result
