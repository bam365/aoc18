let () = 
    AocLib.read_ints stdin
    |> List.fold_left (+) 0
    |> AocLib.print_result
