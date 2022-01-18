module Form
    DEFAULT_FORM_PAGE_NAME = 'UNTITLED_FORM'
    DEFAULT_FORM_ELEMENT_NAME = 'DEFAULT_ELEMENT'

    module ZPL
        extend self
        DEFAULT_FONT = '0'
        Start = "^XA"
        End = "^XZ"
        FieldSeperator = "^FS"
        def LabelLength(l); "^LL#{l}"; end
        def FieldPosition(x, y); "^FO#{x},#{y}"; end
        def FieldData(d); "^FD#{d}"; end
        def GraphicBox(w, h, t, c, r); "^GB#{w},#{h},#{t},#{c},#{r}"; end
        def Font(n = DEFAULT_FONT, w = 1, h = 1); "^A#{n},#{h},#{w}"; end
    end

    class Page
        attr_reader :name, :length

        def initialize(name: DEFAULT_FORM_PAGE_NAME, length: nil)
            @name, @length = name, length
            @form_elements = []
        end

        def set_length(len)
            @length = len
        end

        def to_zpl
            @lines = []
            @lines << ZPL::Start
            @lines << ZPL::LabelLength(@length) unless @length == nil
            @lines << @form_elements.map { |element| element.to_zpl }
            @lines << ZPL::End
            return @lines.join
        end

        def debug
            # ...
        end

        def set_font(n = ZPL::DEFAULT_FONT, w = 1, h = 1)
            @form_elements << Font.new(n, w, h)
        end
    
        def add_box(x = 1, y = 1, w = 1, h = 1)
            @form_elements << Box.new(x, y, w, h)
        end

        def add_text(x = 0, y = 0, d = '', w = 1, h = 1)
            @form_elements << Text.new(x, y, d, w, h)
        end
    end

    class Element
        attr_reader :name

        def initialize(name = DEFAULT_FORM_ELEMENT_NAME)
            @name = name
        end

        def to_zpl
            # ...
        end

        def debug
            puts @name
        end
    end

    class Box < Element
        def initialize(x, y, w, h)
            super("BOX")
            @x, @y, @w, @h = x, y, w, h
            @c, @r = 'B', 0
        end

        def to_zpl
            @lines = []
            @lines << ZPL::FieldPosition(@x, @y)
            @lines << ZPL::GraphicBox(@w, @h, @t, @c, @r)
            @lines << ZPL::FieldSeperator
            return @lines
        end

        def debug
            super
            puts [@x, @y, @w, @h, @c, @r].inspect
        end
    end

    class Text < Element
        def initialize(x = 0, y = 0, d = '', w = 1, h = 1)
            super("TEXT")
            @x, @y, @d, @w, @h = x, y, d, w, h
        end

        def to_zpl
            @lines = []
            @lines << ZPL::FieldPosition(@x, @y)
            @lines << ZPL::Font(ZPL::DEFAULT_FONT, @w, @h)
            @lines << ZPL::FieldData(@d)
            @lines << ZPL::FieldSeperator
            return @lines
        end

        def debug
            super
            puts [@x, @y, @d, @w, @h].inspect
        end
    end

    class Font < Element
        def initialize(n = '0', w = 1, h = 1)
            super('FONT')
            @n, @w, @h = n, w, h
        end

        def to_zpl
            @lines << ZPL.Font(@n, @w, @h)
            
        end

        def debug
            super
            puts [@n, @w, @h].inspect
        end
    end
end
