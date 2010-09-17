ActionController::Routing::Routes.draw do |map|
  
  map.resources :locations

  map.with_options :controller => 'location', :action => 'results' do |l|
    l.travel_cost 'travel-cost'
    l.travel_cost_comparison 'travel-cost-comparison/:location'
  end

  map.with_options :controller => 'contact' do |contact|
    contact.contact '/contact', :action => 'index', :conditions => { :method => :get }
    contact.contact '/contact', :action => 'create', :conditions => { :method => :post }
  end

  map.with_options :controller => "location" do |l|
    l.city_results 'travel-cost/:url', :controller => "location", :action => :results
    l.about_us '/about', :controller => "location", :action => "about"
    l.faq '/faq', :controller => "location", :action => "faq"
    l.terms_privacy '/terms-privacy', :controller => "location", :action => "terms_privacy"
  end

  map.sitemap 'sitemap.xml', :controller => 'sitemap'

  map.root :controller => "location", :action => "start"
end
