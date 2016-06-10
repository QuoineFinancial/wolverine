class Wolverine
  class RemotePathComponent
    class RemoteScriptNotFound < StandardError ; end

    def initialize(path, script_map)
      @path = path
      @script_map = script_map
    end

    def method_missing sym, *args
      create_method sym, *args
      send sym, *args
    end

    private
    def define_directory_method(path, sym, script_map)
      dir = RemotePathComponent.new(path, script_map)
      cb = proc { dir }
      define_metaclass_method(sym, &cb)
    end

    def create_method sym, *args
      if file?(path = @path + "#{sym}.lua")
        define_script_method path, sym, *args
      elsif directory?(path = @path + sym.to_s)
        define_directory_method path, sym
      else
        raise MissingTemplate
      end
    end

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
        Pathname.new(key).ascend do |map_path|
          return true if map_path == path
        end
      end
    end

    def define_metaclass_method sym, &block
      metaclass = class << self; self; end
      metaclass.send(:define_method, sym, &block)
    end
  end
end
