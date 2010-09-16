# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #goes in application helper, as usual
  def bookmark
    title = @title? "'#{@title}'" : "'Compare the cost of travel with Getset'"
    url = "'http://www.getsetapp.com#{request.request_uri}'"
    %Q|<a href="javascript:bookmarksite(#{title}, #{url});">Save this page!</a>|
  end

  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end
end
