require 'date'


# ensure directory exists, like 'mkdir -p'
def mkdir_p(path)
  Dir.mkdir(path) unless File.exists?(path)
end

# grab the uuid of the incident. ignore possible cruft including extension.
# could be better using regex possibly, will do a fancy regex if edgecases bubble up
# TODO(hangtwenty) rename to make clear it takes a URI, not Incident class
def get_incident_uuid(uri)
  last_piece = uri.path.split('/').reject { |s| s.empty? }[-1]
  return last_piece.split(".json")[0]
end

# soft DateTime.parse ... returns nil if given nil
def datetime_or_nil(s)
  return if s.nil?
  DateTime.parse(s)
end
