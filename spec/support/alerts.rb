def have_alert(type, options = {})
  have_selector("div.alert.alert-#{type}", options)
end
