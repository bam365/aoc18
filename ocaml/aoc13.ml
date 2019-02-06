open AocLib


type point = 
    { x: int
    ; y: int
    }
  

module CartState = struct

    type t = 
        { position: point
        ; velocity: SquareAngle.t
        ; turns: SquareAngle.t CCKList.t
        }

    let create point velocity =
        { position = point
        ; velocity = velocity
        ; turns = CCKList.cycle [ 90, 0, 270 ]
        }

    let step t =
        let position' = 
            { x = t.position.x + SquareAngle.sin t.velocity
            ; y = t.position.y + SquareAngle.cos t.velocity
            }
        in { t with position = position' }

    let turn t = 
        let (next_turn, turns' ) = CCKList.(head_exn t.turns, tail_exn t.turns) in
        let velocity' = t.velocity + next_turn |> SquareAngle.normal in
        { t with velocity = velocity'; turns = turns' }

end


