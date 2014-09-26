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
  #@@address = {:origins=>["1803+E+18th+Street+Austin+TX", "2300+W+Ben+White+Blvd+Austin+TX", "1000+E+41st+St+Austin+TX+78751"], :destinations=>["2300+W+Ben+White+Blvd+Austin+TX", "1000+E+41st+St+Austin+TX+78751", "1803+E+18th+Street+Austin+TX"]}
 
  # USING BEN'S AWESOME ALGORITHM:
  # get '/api_request' do
  #   # Make API call to Google:
  #   en_url = URI.encode('https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + @@address[:origins].join("|") + '&destinations='+ @@address[:destinations].join("|") + '&units=imperial&key=' + ENV['GOOGLE_MAPS_KEY'])
  #   # Recieve code vomit:
  #   response = Unirest.get (en_url)
  #   # Orders code vomit in reasonable JSON:
  #   data = response.body
  #   # Empty hash for Ben's data:
  #   algo_data = []
  #   i = 0
  #   # Loop through origin addresses:
  #   while i < data['origin_addresses'].length
  #     org_ary = []
  #     j = 0
  #     # Loop through destination addresses:
  #     while j < data['destination_addresses'].length
  #       dest_ary = []
  #       # Push each destination into the array:
  #       dest_ary << data['destination_addresses'][j]
  #       # Push each destination's distance into the array:
  #       dest_ary << data['rows'][i]['elements'][j]['distance']['value']
  #       # Push the distination array into the origins array:
  #       org_ary << dest_ary
  #       j += 1
  #     end
  #     org_hash = {}
  #     # Create a hash of origin address keys and their data values:
  #     org_hash[data['origin_addresses'][i]] = org_ary
  #     # Push hashes into Ben's array:
  #     algo_data << org_hash
  #     i += 1
  #   end

  # end

  #USING GOOGLE'S SHITTY ALGORITHM:
  #data['routes'].first['legs'].first['steps'].first['html_instructions']
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
    # Adds all of the addresses into an array in the order sorted by Google:
    data['routes'].first['legs'].each_index do |i|
      each_stop << "#{data['routes'].first['legs'][i]['start_address']}: #{data['routes'].first['legs'][i]['distance']['text']}"
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

    binding.pry

    erb :route, :locals => {start_dest: start_dest, points: points_hash, names: names, directions: all_legs, end_dest: end_dest, mode: mode}

  end


  run! if __FILE__ == $0
end


