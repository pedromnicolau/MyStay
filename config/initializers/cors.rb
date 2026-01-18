Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:3000", "localhost:5173", "127.0.0.1"
    resource "*", headers: :any, methods: [ :get, :post, :put, :patch, :delete ]
  end
end
