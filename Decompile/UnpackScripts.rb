# encoding: utf-8
# 该脚本可在RGSS3脚本内或RMVA项目文件夹下运行

# 将Data/Scripts.rvdata2中的RGSS3脚本导出到Unpack/Scripts文件夹
# (添加Unpack/Plugin0、Unpack/Plugin1两个依赖注入点)
# (按顺序加载Unpack/Plugin0、Unpack/Scripts、Unpack/Plugin1，最后运行rgss_main)

unless File.exist?('Unpack')
    # 验证运行环境
    begin
        # 在RGSS3环境内运行
        RGSSReset
        def escapeInvalidFilename(filename)
            filename.gsub(%r{[\\/:*?"<>|%]}) do |char|
                format('%%%02X', char.codepoints.next)
            end
        end
    rescue NameError
        # 在RGSS3环境外运行
        require 'zlib'
        def load_data(path)
            data = File.read(path, File.size(path))
            Marshal.load(data)
        end
        def save_data(obj, path)
            data = Marshal.dump(obj)
            File.new(path, 'wb').syswrite(data)
        end
        def escapeInvalidFilename(filename)
            filename.gsub(%r{[\\/:*?"<>|%]}) do |char|
                format('%%%02X', char.codepoints[0])
            end
        end
    end

    # 创建目录结构
    srcPath = 'Data/Scripts.rvdata2'
    dstPath = 'Unpack/Scripts'
    plugin0 = 'Unpack/Plugin0'
    plugin1 = 'Unpack/Plugin1'
    ['Unpack',dstPath,plugin0,plugin1].each do |i|
        Dir.mkdir(i)
    end

    # 导出内置脚本
    srcData = load_data(srcPath)
    len = srcData.length.to_s.length
    srcData.each_with_index do |ele,idx|
        src = Zlib::Inflate.inflate(ele[2].force_encoding('utf-8'))
        not_blank = src.match(/\S/)
        next unless not_blank || ele[1].match(/\S/)

        idx = '0' * (len - idx.to_s.length) + idx.to_s
        tag = escapeInvalidFilename(ele[1])
        src = not_blank ? "# encoding: utf-8\n" + src.gsub(/\r\n/, "\n") : ''
        File.new("#{dstPath}/#{idx}=#{tag}.rb", 'w').syswrite(src)
    end

    # 配置加载脚本
    srcData = [[0, 'Scripts Loader', Zlib::Deflate.deflate(%(### Scripts Loader ###
$MainCTX = binding()

# 加载在游戏主要脚本之前加载的插件脚本
Dir["#{plugin0}/*.rb"].each do |name|
    eval(File.read(name, File.size(name)), $MainCTX, name)
end

# 屏蔽rgss_main
alias original_rgss_main rgss_main
def rgss_main(&block)
    $MainRUN = block
end

# 加载Data/Scripts.rvdata2导出的脚本
Dir["#{dstPath}/*.rb"].each do |name|
    eval(File.read(name, File.size(name)), $MainCTX, name)
end

# 加载在游戏主要脚本之后加载的插件脚本
Dir["#{plugin1}/*.rb"].each do |name|
    eval(File.read(name, File.size(name)), $MainCTX, name)
end

# 运行rgss_main
original_rgss_main(&$MainRUN)
))]]
    save_data(srcData, srcPath)
end
exit
