class SitemapController < ApplicationController
  def index
     @urls = ['http://getsetapp.com/', 
              'http://getsetapp.com/about', 
              'http://getsetapp.com/contact',
              'http://getsetapp.com/faq' ]

     headers['Content-Type'] = 'application/xml'
     render :layout => false
   end
end
