Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == "admin"
  password == "123456789"
end
