local CardComponent = Class('CardComponent')

function CardComponent:initialize(card)
    self.card = card or {
        type = "plant"
    }
end

return CardComponent