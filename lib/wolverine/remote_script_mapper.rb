class Wolverine
  class RemoteScriptMapper < Struct.new(:redis, :script_map_key)
    def script_map
      @script_map ||= redis.hgetall(script_map_key)
    end
  end
end
