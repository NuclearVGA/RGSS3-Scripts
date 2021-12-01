# encoding: utf-8
# 该脚本可在RGSS3脚本内或RMVA项目文件夹下运行
# (仅适用于运行UnpackScripts.rb后的项目)

# 将Data/*.rvdata2导出到Unpack/Data/*.rvdata2.rb
# 添加了Unpack/Plugin0/ReloadObjects.rb用于从源码载入对象

begin
    # 在RGSS3环境内运行
    RGSSReset
rescue NameError
    # 在RGSS3环境外运行
    src = File.read(__FILE__, File.size(__FILE__))
    File.new('Unpack/Plugin0/ReloadObjects.rb', 'w').syswrite(src)
    `./Game` # 启动RGSS3运行环境
    exit
end

src = %(# encoding: utf-8

class Persistor
    # 序列化对象前进行封装，序列化时反编译为源码并保存，反序列化时自动读取源码并执行
    # e.g. : bin = Marshal.dump(Persistor.new("test.rb", obj))
    # e.g. : obj = Marshal.load(bin)
    def initialize(dst, obj)
        @dst = dst # 保存源码的文件位置
        @obj = obj # 要进行反编译的对象
    end

    def _dump(xxx)
        src = "# encoding: utf-8\\n\#{decompile(@obj).inspect}"
        File.new(@dst, 'w').syswrite(src)
        Marshal.dump(@dst, xxx)
    end

    def self._load(dst)
        dst = Marshal.load(dst)
        eval(File.read(dst, File.size(dst)))
    end
end
)
eval(src)
File.new('Unpack/Plugin0/ReloadObjects.rb', 'w').syswrite(src)

# https://miaowm5.github.io/RMVA-F1/RPGVXAcecn/rgss/g_classes.html
class Table
    def inspect
        tmp = Zlib::Deflate.deflate(Marshal.dump(self))
        "Marshal.load(Zlib::Inflate.inflate(#{tmp.inspect}))"
    end
end
class Color
    alias original_inspect inspect
    def inspect
      "Color.new#{original_inspect}"
    end
end
class Tone
    alias original_inspect inspect
    def inspect
      "Tone.new#{original_inspect}"
    end
end

def decompile(obj)
    # 反编译对象后可通过obj.inspect方法获得源码
    # e.g. : p decompile(obj).inspect
	case obj
	when Numeric, String, Symbol, nil, true, false, Table, Color, Tone
		obj
	when Array
		obj.map { |i| decompile(i) }
	when Hash
		obj.merge(obj) { |_, v1, _| decompile(v1) }
	else
		def obj.inspect
			code = "#{self.class}.allocate.instance_eval {\n"
			instance_variables.each do |k|
				v = instance_variable_get(k)
				code += "\t#{k} = #{decompile(v).inspect}\n"
			end
			"#{code}\tself\n}"
		end
		obj
	end
end

Dir.mkdir('Unpack/Data') unless File.exist?('Unpack/Data')
Dir['Data/*.rvdata2'].each do |name|
    next if name == 'Data/Scripts.rvdata2'
    # 将.rvdata2文件反编译并替换，修改源码后不再需要重新编译
    obj = Persistor.new("Unpack/#{name}.rb", load_data(name))
    save_data(obj, name)
end
exit
