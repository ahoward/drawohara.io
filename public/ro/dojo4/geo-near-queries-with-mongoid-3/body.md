today i was rolling out some new search functionality and really needed the 'geoNear' functionality of mongo

http://docs.mongodb.org/manual/reference/command/geoNear/

unfortunately the mongoid (3) gem doesn't directly support it.

fortunately durran's (https://twitter.com/modetojoy) code is tight enough that a few moments of digging found the solution, and led to this actual code:   


````ruby

# http://stackoverflow.com/questions/5319988/how-is-maxdistance-measured-in-mongodb
#   1° latitude = 69.047 miles = 111.12 kilometers
#

  DEGREES_PER_MILE = 1 / 69.047
  MILES_PER_DEGREE = 1 / DEGREES_PER_MILE

  def Store.find_all_by_lat_lng(lat, lng, options = {})
    options.to_options!

    miles = options[:miles] || 100
    max_distance = miles * DEGREES_PER_MILE

    doc = 
      Mongoid.session(:default).
        command(
          :geoNear     => Store.collection_name,
          :near        => {:lat => lat, :lng => lng},
          :maxDistance => max_distance
        )

    stores = []

    if doc['ok'] == 1.0
      results = Array(doc['results'])

      results.each do |result|
        distance_in_degrees = result['dis']
        obj = result['obj']
        store = Store.instantiate(obj)
        store['distance'] = Float(distance_in_degrees) * MILES_PER_DEGREE
        stores.push(store)
      end
    end

    stores
  end


````