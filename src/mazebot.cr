require "http/client"

module Mazebot
  extend self

  Domain = "https://api.noopschallenge.com"

  def solve(maze : Mazebot::Maze) : String
    valid_range : Range(Int32, Int32) = 0...maze.map.size
    graph = Mazebot::Graph.new

    # Create and add nodes to graph
    maze.map.each_with_index {|row, y|
      row.each_with_index {|char, x|
        node = graph.add_node("#{x},#{y}", location: Mazebot::Coordinate.new(x, y, char))
        maze.start = node if char === "A"
        maze.finish = node if char === "B"
      }
    }

    # Create and add Edges to anything that isn't connected to an "X" space
    graph.node_hash.values.each do |from|
      from
        .adjacent_nodes {|x, y| valid_range.includes?(x) && valid_range.includes?(y) }
        .reject {|node| node.location.character === "X"}
        .each {|to| graph.add_edge(from, to, Mazebot::Maze.manhattan_distance(maze.start.as(Mazebot::Node).location, to.location))}
    end

    dijkstra = Dijkstra.new(graph, maze.start.as(Node))
    solution = dijkstra.shortest_path_to(maze.finish.as(Node))
    directions = solution.map_with_index do |node, index|
      {
        node: node,
        direction: node.location.direction_to(solution[index-1].location).as(String)
      }
    end
    # Remove the starting position
    directions.shift?

    directions
      .map { |tpl| tpl[:direction] }
      .join("")
  end

  def solve(size : Int32) : NamedTuple
    valid_range : Range(Int32, Int32) = 0...size

    response = HTTP::Client.get "#{Mazebot::Domain}/mazebot/random?minSize=#{size}&maxSize=#{size}"

    maze = Mazebot::Maze.from_json(response.body)
    graph = Mazebot::Graph.new

    # Create and add nodes to graph
    maze.map.each_with_index {|row, y|
      row.each_with_index {|char, x|
        node = graph.add_node("#{x},#{y}", location: Mazebot::Coordinate.new(x, y, char))
        maze.start = node if char === "A"
        maze.finish = node if char === "B"
      }
    }

    # Create and add Edges to anything that isn't connected to an "X" space
    graph.node_hash.values.each do |from|
      from
        .adjacent_nodes {|x, y| valid_range.includes?(x) && valid_range.includes?(y) }
        .reject {|node| node.location.character === "X"}
        .each {|to| graph.add_edge(from, to, Mazebot::Maze.manhattan_distance(maze.start.as(Mazebot::Node).location, to.location))}
    end

    dijkstra = Dijkstra.new(graph, maze.start.as(Node))
    solution = dijkstra.shortest_path_to(maze.finish.as(Node))
    directions = solution.map_with_index do |node, index|
      {
        node: node,
        direction: node.location.direction_to(solution[index-1].location).as(String)
      }
    end
    # Remove the starting position
    directions.shift?
    flat_directions = directions
      .map { |tpl| tpl[:direction] }
      .join("")

    response = HTTP::Client.post(
      "#{Mazebot::Domain}#{maze.mazePath}",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: {directions: flat_directions}.to_json
    )

    {
      answer: Mazebot::SolutionResponse.from_json(response.body),
      directions: directions,
      maze: maze,
      solution: solution,
    }
  end
end

require "./mazebot/**"
