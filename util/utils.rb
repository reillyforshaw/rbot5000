def register_page_for_facebook_webhooks(page_token)
  %x[curl -ik -X POST "https://graph.facebook.com/v2.6/me/subscribed_apps?access_token=#{page_token}"]
end
