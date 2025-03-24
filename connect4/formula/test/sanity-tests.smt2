;;;;;;;;;;
;; Minimal test verifying Z3 or CVC5 correctly identifies an array with a finite, enumerated index type as finite.
;;
;; Can we create a universal quantifier over the array's full index range?

;;;;
;; A finite enumerated type

(declare-datatype Color (
  Red  
  Blue  
  Green  
  Yellow  
  Orange  
  Purple  
  Pink
  Brown  
  Black  
  White  
  Gray  
  Cyan  
  Magenta  
  Maroon  
  Olive  
  Navy  
  Teal  
  Lime  
  Indigo  
  Violet  
  Turquoise  
  Gold  
  Silver  
  Beige  
  Tan  
  Peach  
  Coral  
  Lavender  
  Plum  
  Salmon  
  Mint  
  Aqua  
  Burgundy  
  Charcoal  
  Rose  
  Mustard  
  Amber  
  Emerald  
  Sapphire  
  Ruby  
  Ivory  
  Crimson  
  Chocolate  
  Periwinkle  
  Azure  
  Lilac  
  Mauve  
  Bronze  
  Copper  
  Cerulean  
  Fuchsia  
))

(define-const color-names-arr (Array Color String)
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store
  (store ((as const (Array Color String)) "")
    Red "Red")
    Blue "Blue")
    Green "Green")  
    Yellow "Yellow")  
    Orange "Orange")
    Purple "Purple")  
    Pink "Pink")
    Brown "Brown")  
    Black "Black")  
    White "White")  
    Gray "Gray")  
    Cyan "Cyan")  
    Magenta "Magenta")  
    Maroon "Maroon")  
    Olive "Olive")  
    Navy "Navy")  
    Teal "Teal")  
    Lime "Lime")  
    Indigo "Indigo")  
    Violet "Violet")  
    Turquoise "Turquoise")  
    Gold "Gold")  
    Silver "Silver")  
    Beige "Beige")  
    Tan "Tan")  
    Peach "Peach")  
    Coral "Coral")  
    Lavender "Lavender")  
    Plum "Plum")  
    Salmon "Salmon")  
    Mint "Mint")  
    Aqua "Aqua")  
    Burgundy "Burgundy")  
    Charcoal "Charcoal")  
    Rose "Rose")  
    Mustard "Mustard")  
    Amber "Amber")  
    Emerald "Emerald")  
    Sapphire "Sapphire")  
    Ruby "Ruby")  
    Ivory "Ivory")  
    Crimson "Crimson")  
    Chocolate "Chocolate")  
    Periwinkle "Periwinkle")  
    Azure "Azure")  
    Lilac "Lilac")  
    Mauve "Mauve")  
    Bronze "Bronze")  
    Copper "Copper")  
    Cerulean "Cerulean")
    Fuchsia "Fuchsia"))

(declare-datatype Blend (
  (blend
    (c1 Color)
    (c2 Color))))

(define-fun blend.name ((blend Blend)) String
  (str.++ (select color-names-arr (c1 blend)) (select color-names-arr (c2 blend))))

(assert (forall ((blend Blend))
  (< 0 (str.len (blend.name blend)))))

(check-sat)
