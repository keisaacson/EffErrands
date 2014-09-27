require_relative '../lib/efferrands.rb'
require 'sinatra'
require 'pry-byebug'
require 'unirest'
require 'dotenv'

class EffErrands::Server < Sinatra::Application

  set :bind, "0.0.0.0"
  Dotenv.load

  get '/' do
    #home page
    @@user_items = []
    @@start_location = []
    @@end_location = []
    @@travel_mode = nil
    
    erb :index 
  end

  #for index, use this
  post '/add-items' do

    if @@start_location == []
      @@start_location = [params['start_name'], params['start_address']]
      @@travel_mode = params['travel_mode'].to_i
    end

    if params['dest_name']
      @@user_items << [params['dest_name'], params['dest_address']] 
    end

    start_dest = @@start_location
    dests = @@user_items

    erb :index, :locals => {start_dest: start_dest, dests: dests}
  end

  post '/route' do
    #@@user_items = [['Target', '2300 W Ben White Blvd, Austin, TX'], [ 'HEB', '1000 E 41st St Austin, TX 78751']]
    #@@start_location = ['DevHouse', '1803 E 18th Street, Austin, TX']
    #@@end_location = ['MakerSquare Brazos', '800 Brazos St, Austin, TX']

    if params['end_name'].downcase == @@start_location.first.downcase 
      @@end_location = @@start_location
    else
      @@end_location = @@user_items.find {|x| x.first.downcase == params['end_name'].downcase}
      @@user_items.delete(@@end_location)
    end

    #create address hash
    @@address = {}

    #create array for origins key
    @@address[:waypoints] = @@user_items.map {|x| x.last.gsub(/,/, '').gsub(/\s/, '+')}
    @@address[:origin] = @@start_location.last.gsub(/,/, '').gsub(/\s/, '+')

    #create array for destinations key
    @@address[:destination] = @@end_location.last.gsub(/,/, '').gsub(/\s/, '+')

    address = @@address

    redirect '/api_request_waypoints'
  end

  get '/api_request_waypoints' do
    # Make API call to google maps: 
    if @@travel_mode == 0
      new_url = URI.encode('https://maps.googleapis.com/maps/api/directions/json?origin=' + @@address[:origin] + '&destination=' + @@address[:destination] + '&waypoints=optimize:true|' + @@address[:waypoints].join("|") + '&key=' + ENV['GOOGLE_MAPS_KEY'])
    else
      new_url = URI.encode('https://maps.googleapis.com/maps/api/directions/json?origin=' + @@address[:origin] + '&destination=' + @@address[:destination] + '&waypoints=optimize:true|' + @@address[:waypoints].join("|") + '&mode=walking&key=' + ENV['GOOGLE_MAPS_KEY'])
    end
    ordered_response = Unirest.get (new_url)
    # Put the API response in some sort of order:
    data = ordered_response.body

    # Creates some containers for the data:
    points_hash = {}
    each_stop = []
    all_legs = []
        address_for_geocoding = []

    # Adds all of the addresses into an array in the order sorted by Google:
    data['routes'].first['legs'].each_index do |i|
      each_stop << "#{data['routes'].first['legs'][i]['start_address']}: #{data['routes'].first['legs'][i]['distance']['text']}"
      address_for_geocoding << data['routes'].first['legs'][i]['start_address'].gsub(/,/, '').gsub(/\s/, '+')
      sub_leg = []
      data['routes'].first['legs'][i]['steps'].each { |x| sub_leg << x['html_instructions']}
      all_legs << sub_leg
    end
    ## Adds the start point back to the end of the array:
    # each_stop.push(data['routes'].first['legs'].first['start_address'])
    # Adds a key for each address value denoting the order of the trip:
    each_stop.each_index do |i|
      points_hash[i + 1] = each_stop[i]
    end

    index_order = data['routes'].first['waypoint_order']
    start_dest = @@start_location
    dests = @@user_items
    addresses = @@address  
    names = []
    end_dest = @@end_location
    mode = @@travel_mode

    i =0
    while i < dests.length do
      names << dests[index_order[i]].first
      i +=1
    end

    names.unshift(start_dest.first)
    names.push(end_dest.first)
    

    ## GEOCODING API FOR THE MAP:
    # address_for_geocoding.each do |x|
    #   geo_url = URI.encode('https://maps.googleapis.com/maps/api/geocode/json?address=' + x + '&key=' + ENV['GOOGLE_MAPS_KEY'])
    #   response = Unirest.get (geo_url)
    #   geo_data = response.body
    #   geocodes << geo_data['results'].first['geometry']['location']
    # end

    erb :route, :locals => {start_dest: start_dest, points: points_hash, names: names, directions: all_legs, end_dest: end_dest, mode: mode}

  end


  run! if __FILE__ == $0
end






