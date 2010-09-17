class SitemapController < ApplicationController
  def index
     @urls = ['http://www.getsetapp.com/', 
              'http://www.getsetapp.com/about', 
              'http://www.getsetapp.com/contact',
              'http://www.getsetapp.com/faq' ]
     @locations = Iata.sitemap_locations
     
     render :layout => false
   end
end
