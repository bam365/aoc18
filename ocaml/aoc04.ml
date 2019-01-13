open CCFun

module Timestamp = struct
    type t = CalendarLib.Calendar.t

    let format_str = "%F %T"

    let of_string s =
        s ^ ":00"
        |> CalendarLib.Printer.Calendar.from_fstring format_str

    let date = CalendarLib.Calendar.to_date

    let minute = CalendarLib.Calendar.minute

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
        >>= fun guard_name -> 
        BeginsShift(guard_name) |> return
        
            
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

    let compare (t1, _) (t2, _) = CalendarLib.Calendar.compare t1 t2

    let parser action = 
        Timestamp.parser
        >>= fun timestamp ->
        skip_space *> action <* skip_space
        >>= fun action ->
        return (timestamp, action)

    let parser_event_stream =
        let events = 
            parser GuardAction.parser <* skip_white
            |> many
        in
        map (CCList.sort compare) events <* eoi
end        


type sleep_status = Asleep | Awake


module MinuteMap = struct
    type 'a t = 'a array
          
    let empty v = CCArray.init 60 (fun _ -> v)

    let iter_copy t fn =
        let t' = Array.copy t in
        for ind = 0 to 59 do
            fn t' ind
        done;
        t'

    let set_range i j v  = Array.mapi begin fun ind v' ->
        if ind >= i && ind <= j then v else v'
    end

    let count v = 
        CCArray.fold_left (fun acc v' -> if v = v' then acc + 1 else acc) 0

    let map = CCArray.map

    let merge v_merge t1 t2 = iter_copy t1 begin fun t' i ->
        t'.(i) <- v_merge t1.(i) t2.(i)
    end

    let max_ind cmp t = 
        let folder acc i v =
            match acc with
            | None -> Some(i, v)
            | Some(max_i, max_v) -> 
                Some(if cmp v max_v > 0 then (v, i) else (max_v, max_i))
        in
        CCArray.foldi folder None t 
        |> CCOpt.map fst
end


module TimeLog : sig
    module DateMap : CCMap.S
    type entry = string * (sleep_status MinuteMap.t)
    type t = entry DateMap.t
    val empty : t
    val record_sleep : CalendarLib.Date.t -> string -> int -> int -> t -> t
    val most_sleepy : t -> string option
    val sleepiest_minute : string -> t -> int option
end = struct
    module DateMap = CCMap.Make(CalendarLib.Date)

    module IdMap = CCMap.Make(CCString)

    type entry = string * (sleep_status MinuteMap.t)

    type t = entry DateMap.t

    let empty = DateMap.empty

    let record_sleep date id asleep awake = 
        DateMap.update date begin fun v ->
            let mm = CCOpt.(map snd v |> get_or ~default:(MinuteMap.empty Awake)) in
            Some(id, MinuteMap.set_range asleep (awake - 1) Asleep mm)
        end

    let most_sleepy t =
        let folder acc (id, mm) =
            let count = MinuteMap.count Asleep mm in
            IdMap.update id (fun v -> Some(count + (CCOpt.get_or ~default:0 v))) acc
        in
        DateMap.to_list t
        |> CCList.map snd
        |> CCList.fold_left folder IdMap.empty
        |> IdMap.to_list
        |> CCList.sort (fun (_, x) (_, y) -> y - x) (* reverse on purpose *)
        |> CCOpt.of_list
        |> CCOpt.map fst

    let sleepiest_minute id t =
        let open CCList in
        DateMap.to_list t
        |> map snd
        |> filter_map (fun (id', mm) -> if id' = id then Some(mm) else None)
        |> map (MinuteMap.map (function Asleep -> 1 | Awake -> 0))
        |> fold_left (MinuteMap.merge (+)) (MinuteMap.empty 0)
        |> MinuteMap.max_ind (-)
end


let event_stream_to_time_log stream =
    let rec loop_asleep acc date guard_id start_time events = 
        let timelog' min = 
            TimeLog.record_sleep date guard_id start_time min acc
        in
        match events with
        | []    -> timelog' 59
        | (timestamp, action)::events' ->
            let date' = Timestamp.date timestamp in
            GuardAction.(match action with
            | BeginsShift(guard_id') ->
                loop_awake (timelog' 59) date' guard_id' events'
            | FallsAsleep ->
                loop_asleep acc date' guard_id start_time events'
            | WakesUp ->
                let acc' = Timestamp.minute timestamp |> timelog' in
                loop_awake acc' date' guard_id events'
            )

    and loop_awake acc date guard_id = function
        | []    -> acc
        | (timestamp, action)::events' ->
            let date' = Timestamp.date timestamp in
            GuardAction.(match action with
            | BeginsShift(guard_id') -> 
                loop_awake acc date' guard_id' events'
            | FallsAsleep ->
                let start_time = Timestamp.minute timestamp in
                loop_asleep acc date' guard_id start_time events'
            | WakesUp ->
                loop_awake acc date' guard_id events'
            )
    in 
    match stream with
    | (timestamp, GuardAction.BeginsShift(guard_id))::stream' -> 
        let date = Timestamp.date timestamp in 
        loop_awake TimeLog.empty date guard_id stream'
    | _ -> TimeLog.empty

let () = 
    let input = CCIO.read_all stdin in
    match CCParse.parse_string GuardEvent.parser_event_stream input with
    | Result.Error(err) -> "parse error: " ^ err |> print_endline
    | Result.Ok(event_stream) ->
        let timelog = event_stream_to_time_log event_stream in
        let sleepiest_id = 
            TimeLog.most_sleepy timelog
            |> CCOpt.get_exn
        in
        let sleepiest_minute = 
            TimeLog.sleepiest_minute sleepiest_id timelog
            |> CCOpt.get_exn
        in
        (int_of_string sleepiest_id) * sleepiest_minute
        |> AocLib.print_result
