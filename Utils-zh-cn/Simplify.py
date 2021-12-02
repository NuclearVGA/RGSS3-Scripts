# encoding: utf-8
# 该脚本可在RMVA项目文件夹下运行
# (仅适用于运行UnpackObjects.rb后的项目)

# 将项目内所有繁体中文转换为简体中文

import os
import zhconv


def zhcn_name(name: str, root: str):
    # 将文件名转换为简体中文
    temp = zhconv.convert(name, 'zh-cn')
    if name != temp:
        os.rename(f'{root}/{name}', f'{root}/{temp}')
    return temp


for name in os.listdir('.'):
    if name == '.git':
        continue
    name = zhcn_name(name, '.')
    if os.path.isdir(name):
        for root, dirs, files in os.walk(name, False):
            for name in dirs + files:
                zhcn_name(name, root)


def zhcn_text(name: str):
    # 将源代码转换为简体中文
    with open(name, "r", encoding='utf8') as f:
        text = f.read()
    text = zhconv.convert(text, 'zh-cn')
    with open(name, "w", encoding='utf8') as f:
        f.write(text)


for root, _, files in os.walk('Unpack'):
    for name in files:
        zhcn_text(f'{root}/{name}')
