module Mazebot
  struct NodeData
    getter x : Number::Primitive
    getter y : Number::Primitive
    getter character : String

    def initialize(@x : Number::Primitive, @y : Number::Primitive, @character : String)
    end

    def to_s(io)
      io << @x << "," << @y << "=>" << "\"" << @character << "\""
    end
  end

  class Node
    getter data : Mazebot::NodeData
    getter neighbors = Hash(self, Number::Primitive).new
    property parent : self?
    property g : Number::Primitive = Float64::INFINITY
    property f : Number::Primitive = Float64::INFINITY

    def initialize(@data : Mazebot::NodeData = nil)
    end

    def connect_to(node : self, distance : Number::Primitive)
      @neighbors[node] = distance
      node.neighbors[self] = distance
    end

    def direction_to(other : Node) : String?
      if other.data.x < @data.x
        "E"
      elsif other.data.x > @data.x
        "W"
      elsif other.data.y < @data.y
        "S"
      elsif other.data.y > @data.y
        "N"
      else
        nil
      end
    end

    def reset
      @g = Float64::INFINITY
      @f = Float64::INFINITY
      self
    end

    def to_s(io)
      io << @data
    end
  end
end
