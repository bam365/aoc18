open CCFun

module Timestamp = struct
    type t = CalendarLib.Fcalendar.t

    let format_str = "%F %T"

    let of_string s =
        s ^ ":00"
        |> CalendarLib.Printer.Fcalendar.from_fstring format_str

    let parser = 
        let open CCParse in
        char '[' *> chars_if (fun c -> c != ']') <* char ']' 
        >>= fun datestr ->
        try of_string datestr |> return
        with _ -> fail "Malformed timestamp"
end


module GuardAction = struct
    type t =
        | BeginsShift of string
        | FallsAsleep
        | WakesUp

    open CCParse

    let parser_begins_shift = 
        let guard_num = chars_if (is_space %> not) in
        let ending = skip_space *> string "begins shift" in
        string "Guard #" *> guard_num <* ending
        >>= fun guard_name -> BeginsShift(guard_name) |> return
        
            
    let parser_wakes_up = string "wakes up" *> return WakesUp

    let parser_falls_asleep = string "falls asleep" *> return FallsAsleep

    let parser = 
        try_ parser_begins_shift 
        <|> try_ parser_wakes_up 
        <|> parser_falls_asleep
end


module GuardEvent = struct
    type t = Timestamp.t * GuardAction.t

    open CCParse

    let parser action = 
        Timestamp.parser
        >>= fun timestamp ->
        skip_space *> action 
        >>= fun action ->
        return (timestamp, action)

    let parser_event_stream =
        parser GuardAction.parser
        |> sep ~by:endline

    let compare (timestamp_a, _) (timestamp_b, _) = 
        CalendarLib.Fcalendar.compare timestamp_a timestamp_b
end        

let () = print_endline "There's still work to do :)"
