require "time"
require_relative "./old_strategy.rb"

class UserquakeEvaluator
  USERQUAKE_MAXIMUM_INTERVAL_SECONDS = 40

  def initialize(strategy = nil)
    @strategy = strategy || OldStrategy.new
  end

  def evaluate_jsons(jsons)
    # Userquakes, Areapeers に分割して投げ込む
    userquakes = jsons.select { |json| json["code"] == 561 }.sort_by { |json| json["time"] }
    areapeers  = jsons.select { |json| json["code"] == 555 }.sort_by { |json| json["time"] }

    STDERR.puts "グループ化しています..."

    userquake_groups = []
    userquakes.each { |userquake|
      if userquake_groups.empty? ||
          (Time.parse(userquake["time"]) - Time.parse(userquake_groups.last.first["time"])) >= USERQUAKE_MAXIMUM_INTERVAL_SECONDS
        userquake_groups << [userquake]
      else
        userquake_groups.last << userquake
      end
    }
    userquake_groups.select! { |userquake_group| userquake_group.size > 5 }

    STDERR.puts "評価しています..."

    userquake_groups.map { |userquake_group|
      areapeer = areapeers.sort_by { |areapeer| (Time.parse(userquake_group.first["time"]) - Time.parse(areapeer["time"])).abs }.first
      evaluate_userquakes(userquake_group, areapeer)
    }
  end

  def evaluate_userquakes(userquakes, areapeer)
    @strategy.evaluate(userquakes, areapeer)
  end
end

require 'json'

areas = File.readlines("lib/areas.csv").map { |line| line.split(/,/)[0..1] }.map { |items| [items[0].to_i, (items[1].gsub(/ /, "　") + "　" * 10)[0..10]] }.to_h

evaluate_results = UserquakeEvaluator.new.evaluate_jsons(JSON.parse(STDIN.readlines.join()))

evaluate_results.each { |evaluate_result|
  puts "=" * 80 + "\n" +
    "表示: #{evaluate_result[:truly]}\n" +
    "件数: #{evaluate_result[:count_by_area].values.inject(:+)}\n" +
    "表示エリア:\n" +
    evaluate_result[:reliabilities_by_area].
    map { |area, reliability| [area, reliability, evaluate_result[:percent_by_area][area] || 0, evaluate_result[:count_by_area][area]] }.
    sort_by { |items| [items[0]] }.
    map { |items| "  #{sprintf("%s(%3s): %3d件 信頼度%s(%5.1f)", areas[items[0]], items[0], items[3], items[1], items[2])}" }.
    join("\n")
}
