class SitemapController < ApplicationController
  def index
     @urls = ['http://getsetapp.com/', 
              'http://getsetapp.com/about', 
              'http://getsetapp.com/contact',
              'http://getsetapp.com/faq' ]
     @locations = Iata.sitemap_locations
     
     render :layout => false
   end
end
