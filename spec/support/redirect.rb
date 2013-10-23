def errors_on_redirect(path, error_type)
  expect(response).to redirect_to(path)
  get path
  expect(response.body).to have_alert(error_type)
end
