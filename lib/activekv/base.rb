require 'rubygems'
require 'json' rescue nil   # This prevents the json gem loading afterwards and messing up the JSON serialisation
require 'activesupport'

module ActiveKV
  class Base
    # Default the key property and configured state to empty states
    @@configured = nil, false
    
    def initialize(config = {})
      apply_hash!(config)
    end
    
    def to_json(options = {})
      ActiveSupport::JSON.encode(instance_values, options)
    end
    
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
      
      # Try to create a store driver
      driver_name = config.delete 'driver'
      require "moneta/#{driver_name}"
      class_name = Moneta.constants.find { |c| c.to_s.downcase == driver_name.gsub(/_/, "").downcase }
      raise "No implementation found for driver #{config['driver']}" if class_name.nil?
      driver_class = Moneta.const_get(class_name)
      driver_class.new transform_hash(config)
    end
    
    # Requests that the ActiveKV forget its configuration
    def self.unconfigure!
      @@configured = false
    end
    
    class << self # Class Methods
      # Sets the property that will be used to work out the key for the item
      def key(key_prop = nil)
        if key_prop.nil?
          return nil if not defined? @key_prop
          return @key_prop
        end
        
        @key_prop = key_prop
        attr_accessor key_prop
      end
    
      # Changes the pattern used to build keys
      def key_pattern(pattern = nil)
        if pattern.nil?
          return ":class/:key" if not defined? @key_pattern or @key_pattern.nil?
          return @key_pattern
        end
        
        @key_pattern = pattern
      end
      
      # Sets the store that is used for instances of this class
      def store(name)
        @store = name
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
        result.apply_hash!(vals)
        result
      end

      # Creates a store key based on the pattern and provided key
      def create_key(key)
        key_pattern.gsub(':class', self.name).gsub(':key', key)
      end
      
      # Retrieves an instance of the store that is used for this class
      def store_instance
        if defined? @store and defined? @@stores[@store] then 
          @@stores[@store] 
        else 
          @@default_store 
        end
      end
    end
    
    # Saves the record to the appropriate datastore
    def save!
      # Ensure that we have everything we need
      raise NotConfiguredError unless @@configured
      raise NoKeySpecifiedError if self.class.key.nil?
      raise NilKeyError if send(self.class.key).nil?
      
      # Transform ourselves to json, and get our key
      new_val = ActiveSupport::JSON.encode(self)
      key_val = self.class.create_key send(self.class.key)
      
      # Retrieve the appropriate store, and save
      self.class.store_instance[key_val] = new_val
    end
    
    def apply_hash!(props)
      props.each do |k, v|
        send("#{k}=", v)
      end
    end
    
    # Transforms a hash so it also indexes by symbol
    def self.transform_hash h
      result = {}
      h.each do |k,v|
        result_v = if v.is_a? Hash then transform_hash(v) else v end
        
        result[k] = result_v
        result[k.to_sym] = result_v
      end
      result
    end
  end
  
  class NotConfiguredError < Exception
  end
  class NilKeyError < Exception
  end
  class NoKeySpecifiedError < Exception
  end
end

# Patch to the Moneta datamapper class
module Moneta
  class DataMapper
    def []=(key, value)
      obj = @hash.get(key)
      if obj
        obj.value = value
        obj.update
      else
        @hash.create(:the_key => key, :value => value)
      end
    end
  end
end