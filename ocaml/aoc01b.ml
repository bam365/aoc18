module  MySet = CCSet.Make(Int64)

let last_num = Int64.of_int 135638

let rec find_repeated freq set seq = 
    match MySet.mem freq set with
    | true -> Some(freq)
    | false -> begin
        match CCKList.head seq with 
        | None -> None
        | Some(x) -> 
            if Int64.equal x last_num then print_endline "hey" else (); 
            let freq' = Int64.add freq x in
            let set' = MySet.add freq set in
            let seq' = CCKList.drop 1 seq in
            find_repeated freq' set' seq'
    end
        
let () = 
    let freqs = 
        AocLib.read_ints stdin 
        |> List.map Int64.of_int
        |> CCKList.of_list
        |> CCKList.cycle
    in
    let msg = match find_repeated (Int64.of_int 0) MySet.empty freqs with
    | None       -> "(no repeated frequency)"
    | Some(freq) -> Int64.to_string freq 
    in print_endline msg
