val read_ints : in_channel -> int list

val print_result : int -> unit

module IntSet : CCSet.S with type elt = int

module Array2D : sig
    type 'a t = 
        { width : int
        ; height : int
        ; mutable arry : 'a array
        }

    val create : width:int -> height:int -> 'a -> 'a t

    val get : int -> int -> 'a t -> 'a

    val set : int -> int -> 'a -> 'a t -> unit
    
    val update : int -> int -> ('a -> 'a) -> 'a t -> unit

    val merge_unsafe : ('a -> 'a -> 'a) -> int -> int -> src:'a t -> dest:'a t -> unit
end
