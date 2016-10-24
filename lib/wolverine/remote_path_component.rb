class Wolverine
  class RemotePathComponent
    class RemoteScriptNotFound < StandardError ; end
    attr_reader :path, :script_map

    def initialize(path, script_map, options = {})
      @path = path
      @script_map = script_map
      @options = options
      @redis = options[:redis] || Wolverine.redis
      @config = options[:config] || Wolverine.config
    end

    def method_missing sym, *args
      if sha = file?(path = @path + "#{sym}.lua")
        redis, options = @redis, @options
        script = Wolverine::RemoteScript.new(sha, options)
        script.call(redis, *args)
      elsif directory?(path = @path + sym.to_s)
        RemotePathComponent.new(path, script_map)
      else
        raise RemoteScriptNotFound
      end
    end

    private
    def directory?(path)
      @script_map.each do |key, val| 
        Pathname.new(key).dirname.ascend do |map_path|
          return true if map_path == path
        end
      end
      false
    end

    def file?(path)
      @script_map.each do |key, val| 
        return val if Pathname.new(key) == path
      end
      false
    end
  end
end
