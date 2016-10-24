require File.join(File.expand_path('../../test_helper', __FILE__))

class Wolverine
  class RemoteScriptMapperTest < MiniTest::Unit::TestCase
    def redis
      @redis ||= stub(hgetall: :mapping)
    end

    def test_initialize
      rpc = Wolverine::RemoteScriptMapper.new(redis, 'mapping_key')
      assert_equal redis, rpc.redis
      assert_equal 'mapping_key', rpc.script_map_key
      assert_equal :mapping, rpc.script_map
    end
  end
end
