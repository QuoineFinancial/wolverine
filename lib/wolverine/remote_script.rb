class Wolverine
  class RemoteScript
    attr_reader :sha

    def initialize(sha, options = {})
      @sha = sha
      @options = options
    end

    def call(redis, *args)
      begin
        redis.evalsha @sha, *args
      end
    rescue => e
      if LuaError.intercepts?(e)
        raise LuaError.new(e, @sha)
      else
        raise
      end
    end
  end
end
