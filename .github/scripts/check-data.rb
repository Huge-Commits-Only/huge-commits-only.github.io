# Validates _data/projects.yml before the site is built. Fails with a list of every problem found.
require "yaml"

REQUIRED = %w[slug name tagline description points tags icon video poster width height alt accent accent2 links].freeze
projects = YAML.safe_load(File.read("_data/projects.yml"))
abort "BŁĄD: _data/projects.yml musi być listą projektów" unless projects.is_a?(Array) && !projects.empty?

errors = []
seen = {}
projects.each_with_index do |p, i|
  id = p.is_a?(Hash) && p["slug"] ? p["slug"] : "pozycja #{i + 1}"
  unless p.is_a?(Hash)
    errors << "#{id}: wpis musi być słownikiem"
    next
  end
  REQUIRED.each { |k| errors << "#{id}: brak pola #{k}" if p[k].nil? || p[k].to_s.strip.empty? }
  errors << "#{id}: slug: tylko małe litery, cyfry i myślniki" unless p["slug"].to_s.match?(/\A[a-z0-9-]+\z/)
  errors << "#{id}: zduplikowany slug" if seen[p["slug"]]
  seen[p["slug"]] = true
  %w[accent accent2].each { |k| errors << "#{id}: #{k} musi mieć postać #rrggbb" unless p[k].to_s.match?(/\A#\h{6}\z/) }
  %w[width height].each { |k| errors << "#{id}: #{k} musi być liczbą" unless p[k].is_a?(Integer) && p[k].positive? }
  %w[icon video poster].each do |k|
    path = p[k].to_s
    errors << "#{id}: #{k} musi leżeć w assets/projects/" unless path.start_with?("assets/projects/")
    errors << "#{id}: brak pliku #{path}" unless File.file?(path)
  end
  errors << "#{id}: video musi być plikiem .mp4" unless p["video"].to_s.end_with?(".mp4")
  errors << "#{id}: poster musi być plikiem .jpg albo .png" unless p["poster"].to_s.match?(/\.(jpg|png)\z/)
  errors << "#{id}: points: od 2 do 4 punktów" unless p["points"].is_a?(Array) && p["points"].size.between?(2, 4)
  errors << "#{id}: tags: lista" unless p["tags"].is_a?(Array)
  links = p["links"].is_a?(Array) ? p["links"] : []
  errors << "#{id}: co najmniej jeden link" if links.empty?
  links.each do |l|
    errors << "#{id}: link bez etykiety" if l["label"].to_s.strip.empty?
    errors << "#{id}: link #{l['label']} musi zaczynać się od https://" unless l["url"].to_s.start_with?("https://")
  end
  errors << "#{id}: zamiast pauzy „—” użyj przecinka, dwukropka albo kropki" if p.to_s.include?("—")
end

abort(errors.map { |e| "BŁĄD: #{e}" }.join("\n")) unless errors.empty?
puts "OK: #{projects.size} projekty w _data/projects.yml"
