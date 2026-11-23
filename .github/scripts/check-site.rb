# Checks the built site in _site: no scripts, no third-party resources, no broken local links, CSP everywhere.
require "uri"

SITE = "_site"
errors = []
pages = Dir.glob("#{SITE}/**/*.html")
abort "BŁĄD: brak zbudowanej strony w #{SITE}" if pages.empty?

def local_target(page, ref)
  path = URI(ref).path
  path = path.start_with?("/") ? File.join(SITE, path) : File.join(File.dirname(page), path)
  File.directory?(path) ? File.join(path, "index.html") : path
end

pages.each do |page|
  html = File.read(page)
  name = page.delete_prefix("#{SITE}/")
  errors << "#{name}: zawiera <script>" if html.match?(/<script\b/i)
  errors << "#{name}: brak Content-Security-Policy" unless html.include?('http-equiv="Content-Security-Policy"')
  errors << "#{name}: zawiera pauzę „—”" if html.include?("—")
  html.scan(/\s(src|poster|href)="([^"]*)"/).each do |attr, ref|
    next if ref.empty? || ref.start_with?("#", "mailto:")
    if ref.match?(%r{\A[a-z]+://}i)
      # Resources are always local; only plain links may leave the site, and only over HTTPS.
      errors << "#{name}: #{attr}=#{ref} ładuje zasób z zewnątrz" if attr != "href"
      errors << "#{name}: link #{ref} bez HTTPS" unless ref.start_with?("https://")
      next
    end
    errors << "#{name}: #{attr}=#{ref} wskazuje nieistniejący plik" unless File.exist?(local_target(page, ref))
  end
end
css = File.join(SITE, "assets/css/site.css")
# Guards against a theme stylesheet replacing ours: project accents are generated from _data/projects.yml.
errors << "assets/css/site.css nie zawiera stylów projektów" unless File.file?(css) && File.read(css).include?(".project--")
%w[.well-known/security.txt robots.txt sitemap.xml 404.html].each { |f| errors << "brak #{f}" unless File.file?(File.join(SITE, f)) }

abort(errors.map { |e| "BŁĄD: #{e}" }.join("\n")) unless errors.empty?
puts "OK: #{pages.size} stron, bez skryptów i zasobów z zewnątrz"
