# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #goes in application helper, as usual
  def bookmark
    title = @title? "'#{@title}'" : "'Compare the cost of travel with Getset'"
    url = "'http://www.getsetapp.com#{request.request_uri}'"
    %Q|<a href="javascript:bookmarksite(#{title}, #{url});">Save this page!</a>|
  end
end
