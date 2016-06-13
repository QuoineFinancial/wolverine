require 'redis'
require 'pathname'

require 'wolverine/version'
require 'wolverine/configuration'
require 'wolverine/script'
require 'wolverine/path_component'
require 'wolverine/remote_path_component'
require 'wolverine/remote_script_mapper'
require 'wolverine/remote_script'
require 'wolverine/lua_error'

class Wolverine
  # Returns the configuration object for reading and writing
  # configuration values.
  #
  # @return [Wolverine::Configuration] the configuration object
  def self.config
    @config ||= Configuration.new
  end

  # Provides access to the redis connection currently in use by Wolverine.
  #
  # @return [Redis] the redis connection used by Wolverine
  def self.redis
    config.redis
  end

  def self.statsd_enabled?
    @statsd_enabled
  end

  def self.enable_statsd!
    @statsd_enabled = true
  end

  # Resets all the scripts cached by Wolverine. Scripts are lazy-loaded and
  # cached in-memory, so if a file changes on disk, it will be necessary to
  # manually reset the cache using +reset!+.
  #
  # @return [void]
  def self.reset!
    @root_directory = nil
    reset_cached_methods
  end

  # Used to handle dynamic accesses to scripts. Successful lookups will be
  # cached on the {PathComponent} object. See {PathComponent#method_missing}
  # for more detail on how this works.
  #
  # @return [PathComponent, Object] a PathComponent if the method maps to a
  #   directory, or an execution result if the the method maps to a lua file.
  def self.method_missing sym, *args
    root_directory.send(sym, *args)
  rescue PathComponent::MissingTemplate
    super
  end

  def initialize(config = nil)
    @config = config
  end

  def config
    @config ||= self.class.config.dup
  end

  def redis
    config.redis
  end

  def remote?
    config.remote
  end

  def self.remote?
    config.remote
  end

  def reset!
    @root_directory = nil
    reset_cached_methods
  end

  def method_missing sym, *args
    # Disallow access to protected partials (files that begin with _ character)
    if sym[0] == '_'
      super
    else
      root_directory.send(sym, *args)
    end
    
  rescue PathComponent::MissingTemplate
    super
  end

  private
  def remote_script_map
    return nil unless remote?
    @remote_script_map ||= RemoteScriptMapper.new(redis, config.remote_script_map_key).script_map
  end

  def self.remote_script_map
    return nil unless remote?
    @remote_script_map ||= RemoteScriptMapper.new(redis, config.remote_script_map_key).script_map
  end

  def self.root_directory
    @root_directory ||= 
      if remote?
        RemotePathComponent.new('', remote_script_map)
      else
        PathComponent.new(config.script_path, {:cache_to => self})
      end
  end

  def self.cached_methods
    @cached_methods ||= Hash.new
  end

  def self.reset_cached_methods
    metaclass = class << self; self; end
    cached_methods.each_key { |method| metaclass.send(:undef_method, method) }
    cached_methods.clear
  end

  def root_directory
    @root_directory ||= 
      if remote?
        RemotePathComponent.new('', remote_script_map, {:config => config, :redis => redis})
      else
        PathComponent.new(config.script_path, {:cache_to => self, :config => config, :redis => redis})
      end
  end

  def cached_methods
    @cached_methods ||= Hash.new
  end

  def reset_cached_methods
    metaclass = class << self; self; end
    cached_methods.each_key { |method| metaclass.send(:undef_method, method) }
    cached_methods.clear
  end

end
