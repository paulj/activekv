module ActiveKV
  STORE_DRIVERS = {'memory' => Moneta::Memory}
  
  class Base
    # Default the key property and configured state to empty states
    @@configured = nil, false
    
    # Configures the ActiveKV support with the given configuration file
    def self.configure(config_file)
      # Determine our environment
      env = if defined? RACK_ENV then RACK_ENV else :development end
        
      # Load the configuration, and find the appropriate section
      config = YAML::load_file(config_file)
      env_config = config[env.to_s]
      if env_config.nil?
        raise "No configuration found for environment #{env}"
      end
      
      # Work through each store
      @@stores = {}
      @@default_store = nil
      env_config.each do |store_name, store_config|
        @@stores[store_name] = load_store(store_name, store_config)
        @@default_store = @@stores[store_name] if @@default_store.nil?
      end
      
      # Remember that we're configured
      @@configured = true
    end
    
    # Prepares a configuration store based on the given configuration
    def self.load_store(name, config)
      raise "No driver specified in configuration #{store_name}" if config['driver'].nil?
      driver_class = STORE_DRIVERS[config['driver']]
      raise "No implementation found for driver #{config['driver']}" if driver_class.nil?
      
      config.delete 'driver'
      driver_class.new config
    end
    
    # Requests that the ActiveKV forget its configuration
    def self.unconfigure!
      @@configured = false
    end
    
    class << self # Class Methods
      # Default the key pattern
      @@key_pattern = ":class/:key"
    
      # Sets the property that will be used to work out the key for the item
      def key(key_prop)
        @@key_prop = key_prop
        attr_accessor key_prop
      end
    
      # Changes the pattern used to build keys
      def key_pattern(pattern)
        @@key_pattern = pattern
      end
      
      # Sets the store that is used for instances of this class
      def store(name)
        @@store = name
      end
      
      # Finds a record with the given key
      def find(key)
        # Create the key and lookup the value
        key_val = create_key key
        found_val = store_instance[key_val]
        return nil if found_val.nil? or found_val == {}
          # Check if result is {}, because the memory implementation returns this as a default value
          # when the real value isn't found
        
        # Decode the found value, then apply each property in the JSON to the object
        vals = ActiveSupport::JSON.decode(found_val)
        result = new
        vals.each do |k, v|
          result.send("#{k}=", v)
        end
        result
      end

      # Creates a store key based on the pattern and provided key
      def create_key(key)
        @@key_pattern.gsub(':class', self.class.name).gsub(':key', key)
      end
      
      # Retrieves an instance of the store that is used for this class
      def store_instance
        if defined? @@store and defined? @@stores[@@store] then 
          @@stores[@@store] 
        else 
          @@default_store 
        end
      end
    end
    
    # Saves the record to the appropriate datastore
    def save!
      # Ensure that we have everything we need
      raise NotConfiguredError unless @@configured
      raise NoKeySpecifiedError if not defined? @@key_prop
      raise NilKeyError if send(@@key_prop).nil?
      
      # Transform ourselves to json, and get our key
      new_val = to_json
      key_val = self.class.create_key send(@@key_prop)
      
      # Retrieve the appropriate store, and save
      self.class.store_instance[key_val] = new_val
    end
  end
  
  class NotConfiguredError < Exception
  end
  class NilKeyError < Exception
  end
  class NoKeySpecifiedError < Exception
  end
end
