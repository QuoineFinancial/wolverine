require File.join(File.expand_path('../../test_helper', __FILE__))

class Wolverine
  class RemoteScriptTest < MiniTest::Unit::TestCase
    def test_initialize
      script = Wolverine::RemoteScript.new(:sha)
      assert_equal :sha, script.sha
    end

    def test_run
      redis = stub
      script = Wolverine::RemoteScript.new(:sha)
      redis.expects(:evalsha).returns(:success)
      assert_equal :success, script.call(redis)
    end
  end
end
