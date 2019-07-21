require "./node"

class Edge
  property from : Node
  property to : Node
  property weight : Float64

  def initialize(@from : Node, @to : Node, @weight : Float64)
  end

  def <=>(other : Edge)
    self.weight <=> other.weight
  end

  def to_s
    "#{from.to_s} => #{to.to_s} with weight #{weight}"
  end
end
