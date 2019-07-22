require "http/client"
require "json"
require "./mazebot"

puts "Starting new Noops maze race..."
response = HTTP::Client.post(
  "#{Mazebot::Domain}/mazebot/race/start",
  headers: HTTP::Headers{"Content-Type" => "application/json"},
  body: {login: "dhm116"}.to_json
)

solution_response = Mazebot::SolutionResponse.from_json(response.body)

results = Array(Mazebot::SolutionResponse).new

while !solution_response.nextMaze.nil?
  response = HTTP::Client.get "#{Mazebot::Domain}#{solution_response.nextMaze}"
  maze = Mazebot::Maze.from_json(response.body)
  solution = Mazebot.solve(maze)
  response = HTTP::Client.post(
    "#{Mazebot::Domain}#{maze.mazePath}",
    headers: HTTP::Headers{"Content-Type" => "application/json"},
    body: {directions: solution}.to_json
  )
  solution_response = Mazebot::SolutionResponse.from_json(response.body)
  results << solution_response
end

puts "Completed #{results.size} mazes"
results.each do |result|
  puts result.to_json
end
