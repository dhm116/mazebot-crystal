require "http/client"
require "json"
require "./mazebot"
require "uri"

results = Array(Mazebot::SolutionResponse).new

puts "Starting new Noops maze race..."
uri = URI.parse(Mazebot::Domain)
client = HTTP::Client.new(uri)

response = client.post(
  "/mazebot/race/start",
  headers: HTTP::Headers{"Content-Type" => "application/json"},
  body: {login: "dhm116"}.to_json
)

solution_response = Mazebot::SolutionResponse.from_json(response.body)

while !solution_response.nextMaze.nil?
  maze : Mazebot::Maze? = nil
  solution : String? = nil
  local_timing : Hash(String, Float64) = Hash(String, Float64).new
  graph : Mazebot::Graph? = nil
  search_result : Array(Mazebot::Node)? = nil

  elapsed_time = Time.measure do
    response = client.get "#{solution_response.nextMaze}"
  end
  local_timing["fetch_maze"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    maze = Mazebot::Maze.from_json(response.body)
  end
  local_timing["parse_maze"] = elapsed_time.total_milliseconds

  actual_maze = maze.as(Mazebot::Maze)

  elapsed_time = Time.measure do
    graph = Mazebot::Graph.from(actual_maze)
  end
  local_timing["create_graph"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    search_result = Mazebot.search actual_maze.start.as(Mazebot::Node), actual_maze.finish.as(Mazebot::Node) do |node1, node2|
      x, y = node1.data.x.as(Int32), node1.data.y.as(Int32)
      to_x, to_y = node2.data.x.as(Int32), node2.data.y.as(Int32)
      ((x - to_x).abs + (y - to_y).abs).to_i
    end
  end
  local_timing["a_star_search"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    unless search_result.nil?
      node_path = search_result.as(Array(Mazebot::Node))
      solution = node_path.map {|node|
        node.direction_to(node.parent.as(Mazebot::Node)) if node.parent
      }.join("")
    end
  end
  local_timing["stringify_solution"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    response = client.post(
      "#{maze.as(Mazebot::Maze).mazePath}",
      headers: HTTP::Headers{"Content-Type" => "application/json"},
      body: {directions: solution.as(String)}.to_json
    )
  end
  local_timing["submit_solution"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    solution_response = Mazebot::SolutionResponse.from_json(response.body)
  end
  local_timing["parse_solution_response"] = elapsed_time.total_milliseconds

  local_timing["total_duration"] = local_timing.values.reduce{|acc,val| acc + val}
  solution_response.size = maze.as(Mazebot::Maze).size
  solution_response.local_timing = local_timing
  results << solution_response
end

client.close

puts "Completed #{results.size} mazes"
results.each do |result|
  puts result.to_pretty_json
end
