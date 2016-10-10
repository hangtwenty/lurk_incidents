require 'date'

# TODO review this way of doing the classes/subclasses ... 
# got some analysis paralysis with this, since people talk so much bad about plain old inheritance in ruby... 
# JFDI but did I do it OK?
# This class is assuming JSON as the data and all the method implementations are against the JSON.
# but you could easily code a class that subclasses or is just a 'duck' w/ same methods, that works on HTML/scrape.
class Incident

  STATUSES_RESOLVED = ["completed", "resolved", "postmortem"]

  # Initialize with data, e.g. a hash parsed from StatusPage /incidents/#{uuid}.json.
  def initialize( data )
    @data = data
  end

  # unique hash-id from statuspage. from json.
  def uuid
    @data["id"]
  end

  # when the incident started
  def started_at
    DateTime.parse(@data["created_at"])
  end

  # status field.
  def status
    @data["status"].downcase
  end

  # is resolved/completed/postmortem. anything meaning "not still changing."
  def is_ended
    STATUSES_RESOLVED.include? status
  end

  # when the incident ended, if it did...
  def ended_at
    if is_ended
      # edge case I've seen & want to handle: incident has really ended, 
      # and it's marked 'resolved', but only have 'updated_at' ...
      # Since we already know it's marked resolved, take the earlier one.
      resolved_at = @data["resolved_at"] && DateTime.parse(@data["resolved_at"])
      updated_at = @data["updated_at"] && DateTime.parse(@data["updated_at"])
      if resolved_at and updated_at
        return [resolved_at, updated_at].min
      else
        return updated_at || resolved_at
      end
    else
      return nil
    end
  end

  # time between start and end, in seconds
  def duration_seconds
    if started_at && ended_at
      # subtracting two DateTimes returns time in days. convert to seconds.
      ((ended_at - started_at) * 24 * 60 * 60)
    else
      nil
    end
  end

  def duration_minutes
    duration_seconds / 60
  end

  def duration_hours
    duration_minutes / 60
  end

  # inspect most vital fields, do NOT print whole @data again :)
  def inspect
    "Incident(uuid: #{uuid}, status: #{status}, started_at: #{started_at}, " +
    "ended_at: #{ended_at}, duration_seconds: #{duration_seconds}, ...)"
  end
end 
      

####impact              ( .impact_override || .impact )
####scheduled           ( .title.contains('planned').or.contains('scheduled') || `!.scheduled_*.nil?`)

####updates             ... could keep the list of updates ... as mentioned earlier could be cool to do fancy overlay graphing of timelines, but ...
####    .count          ... just count for now :) that will work for initial graphing

####blurb               ( .postmortem_body + .incident_updates.body[].join )
####keywords            blurb | keyword_extraction()   # use:       https://github.com/domnikl/highscore || https://github.com/louismullie/graph-rank

####publicized          [tweeted ( .twitter* ) ]
