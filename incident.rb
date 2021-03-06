require 'active_support'
require 'active_support/core_ext/object/blank'

require './util.rb'

# TODO review this way of doing the classes/subclasses ... 
# got some analysis paralysis with this, since people talk so much bad about plain old inheritance in ruby... 
# JFDI but did I do it OK?
# This class is assuming JSON as the data and all the method implementations are against the JSON.
# but you could easily code a class that subclasses or is just a 'duck' w/ same methods, that works on HTML/scrape.
class Incident

  STATUSES_RESOLVED = ["completed", "resolved", "postmortem"]
  BLURB_SEPARATOR = "\n\n"

  # Initialize with data, e.g. a hash parsed from StatusPage /incidents/#{uuid}.json.
  def initialize( data )
    @data = data
  end

  # unique hash-id from statuspage. from json.
  def uuid
    @data["id"]
  end

  # status field.
  def status
    @data["status"].downcase
  end

  # enum/string of impact.
  # statuspage says these are the values:
  #   None (black)
  #   Minor (yellow)
  #   Major (orange)
  #   Critical (red)
  #   Maintenance (black)
  def impact
    (@data["impact_override"] || @data["impact"] || "None").downcase
  end

  # this is homespun but, just devising a way to graph impacts
  # statuspage says these are the values:
  #   None (black)
  #   Minor (yellow)
  #   Major (orange)
  #   Critical (red)
  #   Maintenance (black)
  def impact_rank
    #numbers picked rather wantonly from fibonacci sequence
    case impact.downcase
      when "critical"
        34
      when "major"
        13
      when "minor"
        5
      when "maintenance"
        1
      else
        0
    end 
  end

  # is resolved/completed/postmortem. anything meaning "not still changing."
  def is_ended
    STATUSES_RESOLVED.include? status
  end

  # when the incident started. picks earliest of several options.
  # (this is more squirrely than you'd think... see tricky_start_time fixture)
  def started_at
    choices = [
      datetime_or_nil(@data["created_at"]),
      *extract_update_datetimes
    ].reject(&:nil?)
    choices.min
  end

  # get (raw) updates iterable
  # TODO(hangtwenty) create 'update' class probably...
  def updates
    @data['incident_updates'].map{|it| Update.new it}
  end

  # since I have done this a number of times, and it can look a little cryptic
  def started_month_name
    started_at.strftime("%m - %b")
  end

  # i.e. week 47, week 52 etc. Starting from Sunday.
  def started_week_number
    started_at.strftime("%U")
  end

  # when the incident ended, if it did...
  # FIXME(hangtwenty) does this need some kinda update to the effect of started_at
  def ended_at
    if is_ended
      # edge case I've seen & want to handle: incident has really ended, 
      # and it's marked 'resolved', but only have 'updated_at' ...
      # Since we already know it's marked resolved, take the earlier one.
      resolved_at = @data["resolved_at"] && datetime_or_nil(@data["resolved_at"])
      updated_at = @data["updated_at"] && datetime_or_nil(@data["updated_at"])
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

  def name
    @data["name"]
  end

  # join together plaintext blurbs for all updates 
  def blurb_updates
    updates
        .sort_by{|update| update.all_datetimes.reject(&:nil?).min}
        .map(&:body).reject(&:blank?).join(BLURB_SEPARATOR)
  end

  # join together names and descriptions of components
  def blurb_components
    # from API Docs: "key only present if component subscriptions are enabled"
    if @data.key? "components"
      comps = @data["components"].map{|comp_data|
        name = comp_data["name"] || 'unnamed_component'
        desc = comp_data["description"]
        if !desc.nil? && !desc.empty?
          "#{name} (#{desc})"
        else
          name
        end
      }.reject(&:nil?).sort
      if !comps.empty?
        "Components affected: #{comps.join(", ")}."
      else
        ""
      end
    else
      ""
    end
  end

  # overall plaintext blurb using incident.name, update blurbs, components
  def blurb
    [name, blurb_updates, postmortem_body, blurb_components]
        .reject(&:blank?).join(BLURB_SEPARATOR)
  end

  # direct field from json, 'postmortem_body'
  def postmortem_body
    # ^ wow etymology is fun, literal interpretation is such a diff. meaning
    @data["postmortem_body"] || ""
  end

  # inspect most vital fields, do NOT print whole @data again :)
  def inspect
    "Incident(uuid: #{uuid}, status: #{status}, started_at: #{started_at}, " +
    "ended_at: #{ended_at}, duration_seconds: #{duration_seconds}, ...)"
  end

  private
    # get all datetimes from all incident.updates
    def extract_update_datetimes 
      updates.map(&:all_datetimes).flatten.reject(&:nil?)
    end
end 
      

class Update

  def initialize(update_data)
    @data = update_data
  end

  # all datetimes (that I care about)
  def all_datetimes
    [created_at, display_at, twitter_updated_at, updated_at]
  end
  
  def created_at
    datetime_or_nil @data["created_at"]
  end

  def display_at
    datetime_or_nil @data["display_at"]
  end

  def updated_at
    datetime_or_nil @data["updated_at"]
  end

  def twitter_updated_at
    datetime_or_nil @data["twitter_updated_at"]
  end

  def body
    @data["body"] || ""
  end

end


####blurb               ( .postmortem_body + .incident_updates.body[].join )
####keywords            blurb | keyword_extraction()   # use:       https://github.com/domnikl/highscore || https://github.com/louismullie/graph-rank
