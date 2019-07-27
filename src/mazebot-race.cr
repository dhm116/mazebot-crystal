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

  elapsed_time = Time.measure do
    response = client.get "#{solution_response.nextMaze}"
  end
  local_timing["fetch_maze"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    maze = Mazebot::Maze.from_json(response.body)
  end
  local_timing["parse_maze"] = elapsed_time.total_milliseconds

  elapsed_time = Time.measure do
    solution = Mazebot.solve(maze.as(Mazebot::Maze))
  end
  local_timing["solve_maze"] = elapsed_time.total_milliseconds

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
