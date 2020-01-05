require "time"

class UserquakeEvaluator
  USERQUAKE_MAXIMUM_INTERVAL_SECONDS = 40

  def self.evaluate_jsons(jsons)
    # Userquakes, Areapeers に分割して投げ込む
    userquakes = jsons.select { |json| json["code"] == 561 }.sort_by { |json| json["time"] }
    areapeers  = jsons.select { |json| json["code"] == 555 }.sort_by { |json| json["time"] }

    userquake_groups = []
    userquakes.each { |userquake|
      if userquake_groups.empty? ||
          (Time.parse(userquake["time"]) - Time.parse(userquake_groups.last.first["time"])) >= USERQUAKE_MAXIMUM_INTERVAL_SECONDS
        userquake_groups << [userquake]
      else
        userquake_groups.last << userquake
      end
    }

    userquake_groups.map { |userquake_group|
      areapeer = areapeers.sort_by { |areapeer| (Time.parse(userquake_group.first["time"]) - Time.parse(areapeer["time"])).abs }.first
      evaluate_userquakes(userquake_group, areapeer)
    }
  end

  def self.evaluate_userquakes(userquakes, areapeer)
    # TODO: Not implemented
    [userquakes.first["time"], areapeer["time"], Time.parse(userquakes.first["time"]) - Time.parse(areapeer["time"])]
  end
end
