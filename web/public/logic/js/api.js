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