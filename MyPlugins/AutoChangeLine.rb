# encoding: utf-8

# 该脚本在定义Window_Base类之后运行

class Window_Base
    def process_character(c, text, pos)
        case c
        when "\n"   # 改行
            process_new_line(text, pos)
        when "\f"   # 改ページ
            process_new_page(text, pos)
        when "\e"   # 制御文字
            process_escape_character(obtain_escape_code(text), text, pos)
        else        # 普通の文字
            text_width = text_size(c).width
            process_new_line(text, pos) if contents_width - pos[:x] < text_width
            draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
            pos[:x] += text_width
        end
    end
end
