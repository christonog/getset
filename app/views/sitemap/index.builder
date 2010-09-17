xml.instruct! :xml, :version => '1.0'

xml.urlset 'xmlns' => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @urls.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod     w3c_date(Time.now)
      xml.changefreq  "always"
    end
  end

  @locations.each do |l|
    xml.url do
      xml.loc travel_cost_comparison_url(l)
      xml.lastmod     w3c_date(Time.now)
      xml.changefreq  "always"
    end
  end
end
