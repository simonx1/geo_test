require 'bundler'
Bundler.require


configure do
  set :home, Geokit::LatLng.new(51.752496, -1.271778)
  set :db, MaxMindDB.new('./GeoLite2-City.mmdb')
end

error do
end

helpers do
end

before do
  content_type :json
end

get '/?:ip?' do
  ip = params[:ip] || env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
  ret = settings.db.lookup(ip)

  if ret.found?
    { 
      country: ret.country.name,
      iso: ret.country.iso_code,
      city: ret.city.name,
      latitude: ret.location.latitude,
      longitude: ret.location.longitude
    }.to_json
  elsif ip == '127.0.0.1'
    halt 'Use "/<ip_address>" from localhost'
  else
    halt 404
  end
end

get '/dist/?:ip?' do
  ip = params[:ip] || env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
  ret = settings.db.lookup(ip)

  if ret.found?
    dest = Geokit::LatLng.new(ret.location.latitude, ret.location.longitude)
    {
      distance: settings.home.distance_to(dest),
      units: Geokit::default_units
    }.to_json
  elsif ip == '127.0.0.1'
    halt 'Use "/<ip_address>" from localhost'
  else
    halt 404
  end
end
