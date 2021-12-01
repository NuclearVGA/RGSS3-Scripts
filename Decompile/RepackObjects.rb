# encoding: utf-8
# 该脚本可在RGSS3脚本内或RMVA项目文件夹下运行
# (仅适用于运行UnpackScripts.rb后的项目)

# 将Data/*.rvdata2重新封装回标准的rvdata2格式

begin
    # 在RGSS3环境内运行
    RGSSReset
    Dir['Data/*.rvdata2'].each do |name|
        next if name == 'Data/Scripts.rvdata2'
        save_data(load_data(name), name)
    end
    File.delete('Unpack/Plugin0/RepackObjects.rb')
rescue NameError
    # 在RGSS3环境外运行
    src = File.read(__FILE__, File.size(__FILE__))
    f = File.new('Unpack/Plugin0/RepackObjects.rb', 'w')
    f.syswrite(src)
    f.close()
    `./Game` # 启动RGSS3运行环境
end
exit
