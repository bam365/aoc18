open CCFun

let read_ints =
    CCIO.read_lines_l
    %> List.map int_of_string

let print_result n = 
    print_int n;
    print_endline ""

module IntOrdered = struct type t = int
    let compare = ( - )
end

module IntSet = CCSet.Make(IntOrdered)

module Array2D = struct
    type 'a t = 
        { width : int
        ; height : int
        ; mutable arry : 'a array
        }

    let create ~width ~height v =
        { width
        ; height
        ; arry = Array.make (width * height) v
        }

    let idx x y t = y * t.width + x

    let get x y t = t.arry.(idx x y t)

    let set x y v t = 
        Array.set t.arry (idx x y t) v

    let update x y fn t =
        let v = get x y t in set x y (fn v) t

    let merge_unsafe fn x_off y_off ~src ~dest =
        for x = 0 to (src.width - 1) do
            for y = 0 to (src.height - 1) do
                update (x + x_off) (y + y_off) (fun v -> fn v (get x y src)) dest
            done
        done
end
