module Mazebot
  struct Coordinate
    getter character : String | Char
    getter x : Int32
    getter y : Int32

    def initialize(@x, @y, @character)
    end

    def direction_to(other : Coordinate) : String?
      if other.x < @x
        "E"
      elsif other.x > @x
        "W"
      elsif other.y < @y
        "S"
      elsif other.y > @y
        "N"
      else
        nil
      end
    end

    def to_s
      "#{x},#{y}"
    end

    def to_s(io)
      io << x << "," << y
    end
  end

  class Node
    property graph : Mazebot::Graph
    property name : String
    property location : Coordinate

    def initialize(@name : String)
      @graph = nil
      @location = nil
    end

    def initialize(@name : String, @location : Coordinate)
      @graph = nil
    end

    def initialize(@name : String, @graph : Mazebot::Graph)
      @location = nil
    end

    def initialize(@name : String, @location : Coordinate, @graph : Mazebot::Graph)
    end

    def adjacent_nodes(&block : (Int32, Int32) -> Bool) : Array(Node)
      [
        [@location.x - 1, @location.y],
        [@location.x + 1, @location.y],
        [@location.x, @location.y - 1],
        [@location.x, @location.y + 1]
      ].select { |(x, y)| block.call(x, y) }
        .map { |(x, y)| graph.node_hash["#{x},#{y}"] }
        .reject { |node| node.nil? }
        .as(Array(Node))
    end

    def adjacent_edges : Array(Mazebot::Edge)
      if @graph.nil?
        return [] of Edge
      end
      return @graph.as(Mazebot::Graph).edges.select{|e| e.from == self}
    end

    def to_s
      @name
    end

    def to_s(io)
      io << @name
    end
  end
end
