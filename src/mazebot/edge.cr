module Mazebot
  struct Edge
    getter from : Mazebot::Node
    getter to : Mazebot::Node
    getter weight : Float64

    def initialize(@from : Mazebot::Node, @to : Mazebot::Node, @weight : Float64)
    end

    def <=>(other : Edge)
      self.weight <=> other.weight
    end

    def to_s
      "#{from.to_s} => #{to.to_s} with weight #{weight}"
    end

    def to_s(io)
      io << from << " => " << to << " with weight " << weight
    end
  end
end
