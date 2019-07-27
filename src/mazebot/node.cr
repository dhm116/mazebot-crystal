module Mazebot
  struct Point
    property x, y

    def initialize(@x : Int32, @y : Int32)
    end
  end

  class Node
    getter character : String
    getter graph : Mazebot::Graph
    getter point : Mazebot::Point

    def initialize(@point : Mazebot::Point, @character : String, @graph : Mazebot::Graph)
    end

    def adjacent_nodes(&block : (Mazebot::Point) -> Bool) : Array(Mazebot::Node)
      [
        Mazebot::Point.new(@point.x - 1, @point.y),
        Mazebot::Point.new(@point.x + 1, @point.y),
        Mazebot::Point.new(@point.x, @point.y - 1),
        Mazebot::Point.new(@point.x, @point.y + 1)
      ].select { |point| block.call(point) }
        .map { |point| @graph.node_hash[point] }
        .reject { |node| node.nil? }
        .as(Array(Mazebot::Node))
    end

    def adjacent_edges : Array(Mazebot::Edge)
      if @graph.nil?
        return [] of Mazebot::Edge
      end
      return @graph.as(Mazebot::Graph).edges.select{|e| e.from == self}
    end

    def direction_to(other : Node) : String?
      if other.point.x < @point.x
        "E"
      elsif other.point.x > @point.x
        "W"
      elsif other.point.y < @point.y
        "S"
      elsif other.point.y > @point.y
        "N"
      else
        nil
      end
    end

    def to_s(io)
      io << @character << "@" << @point.x << ", " << @point.y
    end
  end
end
