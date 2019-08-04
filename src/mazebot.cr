require "http/client"

module Mazebot
  extend self

  Domain = "https://api.noopschallenge.com"

  def solve(maze : Mazebot::Maze) : String
    graph = Mazebot::Graph.from(maze)

    dijkstra = Dijkstra.new(graph, maze.start.as(Mazebot::Node))
    solution = dijkstra.shortest_path_to(maze.finish.as(Mazebot::Node))
    directions = solution.map_with_index do |node, index|
      {
        node: node,
        direction: node.direction_to(solution[index-1]).as(String)
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
    graph = Mazebot::Graph.from(maze)

    dijkstra = Dijkstra.new(graph, maze.start.as(Mazebot::Node))
    solution = dijkstra.shortest_path_to(maze.finish.as(Mazebot::Node))
    directions = solution.map_with_index do |node, index|
      {
        node: node,
        direction: node.direction_to(solution[index-1]).as(String)
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

    # Runs A* search from `start` to `goal` and uses block as heuristic function.
  # Returns `Array(T)` or `Nil` if no path was found.
  def search(start : Mazebot::Node, goal : Mazebot::Node, &block)
    open = [] of Mazebot::Node
    closed = [] of Mazebot::Node
    open << start
    start.g = 0
    start.f = yield start, goal

    until open.empty?
      current = open.min_by { |a| a.f }
      return reconstruct_path goal if current == goal
      open.delete current
      closed << current

      current.neighbors.each do |neighbor, distance|
        next if closed.includes? neighbor
        open << neighbor unless open.includes? neighbor
        if (new_g = current.g + distance) < neighbor.g
          neighbor.parent = current
          neighbor.g = new_g
          neighbor.f = new_g + yield neighbor, goal
        end
      end
    end
    open.map! &.reset
    closed.map! &.reset
    nil
  end

  # Reconstructs the path based on a `Node` (usually the goal).
  # Returns path as an `Array` with start being the first element and goal last.
  def reconstruct_path(node)
    path = [] of typeof(node)
    path << node
    while node = node.parent
      path << node
    end
    path.reverse!
  end

end

require "./mazebot/**"
