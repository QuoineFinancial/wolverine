require File.join(File.expand_path('../../test_helper', __FILE__))

class Wolverine
  class RemotePathComponentTest < MiniTest::Unit::TestCase
    def test_initialize
      rpc = Wolverine::RemotePathComponent.new(:path, :script_map_tree)
      assert_equal :path, rpc.path
      assert_equal :script_map, rpc.script_map
    end

    def test_calling_sub_folder
      rpc = Wolverine::RemotePathComponent.new(Pathname.new('a/b/c'), {'a/b/c/d/e' => 'abc'})
      assert_equal Wolverine::RemotePathComponent, rpc.d.class
      assert_equal 'a/b/c/d', rpc.d.path.to_s
    end

    def test_calling_file
      rpc = Wolverine::RemotePathComponent.new('a/b/c/d', {'a/b/c/d/e' => 'abc'})
      assert_equal Wolverine::RemoteScript, rpc.e.class
    end
  end
end
