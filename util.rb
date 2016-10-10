# ensure directory exists, like 'mkdir -p'
def mkdir_p(path)
  Dir.mkdir(path) unless File.exists?(path)
end

# grab the uuid of the incident. ignore possible cruft including extension.
# could be better using regex possibly, will do a fancy regex if edgecases bubble up
def get_incident_uuid(uri)
  last_piece = uri.path.split('/').reject { |s| s.empty? }[-1]
  return last_piece.split(".json")[0]
end

