# require "graphlb"
require "http/client"
require "json"
require "./dijkstra"
require "./edge"
require "./graph"
require "./node"

# module Mazebot::Crystal
#   VERSION = "0.1.0"

#   # TODO: Put your code here
# end

GridSize = 10
ValidRange = 0...GridSize

class ExampleSolution
  JSON.mapping(
    directions: String
  )
end

class Maze
  property start : (Node)?
  property finish : (Node)?

  JSON.mapping(
    name: String,
    mazePath: String,
    startingPosition: Array(Int32),
    endingPosition: Array(Int32),
    message: String,
    exampleSolution: {type: ExampleSolution, nillable: true},
    map: Array(Array(String))
  )

  def self.manhattan_distance(from : Coordinate, to : Coordinate) : Float64
    ((from.x - to.x).abs + (from.y - to.y).abs).to_f
  end

  def print
    self.print { |x, y, char| char }
  end

  def print(&block : Int32, Int32, String -> String)
    just_spacing = Math.log10(GridSize).to_i + 2
    rows = self.stringify_rows(&block)
    rows = rows.map_with_index do |row, y|
      l_row_number = "#{y}".ljust(just_spacing)
      r_row_number = "#{y}".rjust(just_spacing)
      "|#{l_row_number}|#{row}|#{r_row_number}|"
    end

    width = rows.max_of {|row| row.size}
    # Top Border
    puts "".rjust(width, '_')

    rows.each {|row|
      puts row
      # puts "|".ljust(width - 1, '-') + "|"
    }

    # Bottom Border
    puts "".rjust(width, '-')
    start_s = "Start=[#{@start.as(Node).location.to_s}]"
    end_s = "End=[#{@finish.as(Node).location.to_s}]"
    puts start_s.rjust(start_s.size + 4)
    puts end_s.rjust(end_s.size + 4)
    puts "".rjust(width, '-')
  end

  def stringify_rows(&block : Int32, Int32, String -> String) : Array(String)
    max_cell_width = (GridSize**2).to_s().size
    @map.map_with_index do |row, y|
      cells = row.map_with_index do |character, x|
        block.call(x, y, character)
      end
      # cells.map! {|c| c.rjust(max_cell_width, ' ')}
      cells.join("")
    end
  end
end

response = HTTP::Client.get "https://api.noopschallenge.com/mazebot/random?minSize=#{GridSize}&maxSize=#{GridSize}"

maze = Maze.from_json(response.body)
graph = Graph.new

puts "Creating nodes"
maze.map.each_with_index {|row, y|
  row.each_with_index {|char, x|
    node = graph.add_node("#{x},#{y}", location: Coordinate.new(x, y, char))
    if maze.start.nil? || maze.finish.nil?
      case char
      when "A"
        maze.start = node
      when "B"
        maze.finish = node
      end
    end
  }
}

puts "Adding edges"
graph.node_hash.values.each {|from|
  from
    .adjacent_nodes {|x, y| ValidRange.includes?(x) && ValidRange.includes?(y) }
    .reject {|node| node.location.character === "X"}
    .each {|to| graph.add_edge(from, to, Maze.manhattan_distance(maze.start.as(Node).location, to.location))}
}

dijkstra = Dijkstra.new(graph, maze.start.as(Node))

puts "Getting shortest path"
solution = dijkstra.shortest_path_to(maze.finish.as(Node))

directions = solution.map_with_index { |node, index|
    {node: node, direction: node.location.direction_to(solution[index-1].location).as(String)}
  }

# Remove the starting position
directions.shift?

flat_directions = directions
.map { |tpl| tpl[:direction] }
.join("")

response = HTTP::Client.post(
  "https://api.noopschallenge.com#{maze.mazePath}",
  headers: HTTP::Headers{"Content-Type" => "application/json"},
  body: "{\"directions\":\"#{flat_directions}\"}"
)

directions_hash = directions.index_by { |tpl| {tpl[:node].location.x, tpl[:node].location.y} }

maze.print()

puts "Shortest path is #{directions.size} steps"
puts (directions
  .map { |tpl| tpl[:direction] }
  .join(" => ")
)

maze.print { |x,y,char|
  unless ["A", "B"].includes?(char)
    if directions_hash.has_key?({x,y})
      next directions_hash[{x,y}][:direction]
    end
  end
  next char
}

puts response.body
