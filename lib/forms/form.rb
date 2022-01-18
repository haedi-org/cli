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
        def Comment(d); "^FX#{d}"; end
        def BarcodeField(w = 2, r = 3, h = 10); "^BY#{w},#{r},#{h}"; end
        def Code128(o = 'N'); "^BC#{o}"; end
    end

    module Symbology
        Default = 'code128'
        Code128 = 'code128'
    end

    class Page
        attr_reader :name, :length

        def initialize(name: DEFAULT_FORM_PAGE_NAME, length: nil)
            @name, @length = name, length
            @form_elements = []
        end

        def to_zpl
            arr = []
            arr << ZPL::Start
            arr << ZPL::LabelLength(@length) unless @length == nil
            arr << @form_elements.map { |element| element.to_zpl }
            arr << ZPL::End
            return arr
        end

        def debug
            # ...
        end

        def set_length(length)
            @length = length
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

        def add_barcode(x = 0, y = 0, d = '', sym = Symbology::Default)
            @form_elements << Barcode.new(x, y, d)
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
            arr = []
            arr << ZPL::Comment(@name)
            arr << ZPL::FieldPosition(@x, @y)
            arr << ZPL::GraphicBox(@w, @h, @t, @c, @r)
            arr << ZPL::FieldSeperator
            return arr
        end

        def debug
            super
            puts [@x, @y, @w, @h, @c, @r].inspect
        end
    end

    class Barcode < Element
        def initialize(x = 0, y = 0, d = '', w = 2, r = 3, h = 10, 
        symbology: Symbology::Default)
            super("BARCODE")
            @x, @y, @d = x, y, d
            @w, @r, @h = w, r, h
            @symbology = symbology
        end

        def to_zpl
            arr = []
            arr << ZPL::Comment(@name)
            arr << ZPL::BarcodeField(@w, @r, @h)
            arr << ZPL::FieldPosition(@x, @y)
            case @symbology
                when Symbology::Code128; arr << ZPL::Code128()
                else; arr << ZPL::Code128()
            end
            arr << ZPL::FieldData(@d)
            arr << ZPL::FieldSeperator
            return arr
        end

        def debug
            super
            puts [@x, @y, @d, @w, @r, @h].inspect
        end
    end

    class Text < Element
        def initialize(x = 0, y = 0, d = '', w = 1, h = 1)
            super("TEXT")
            @x, @y, @d, @w, @h = x, y, d, w, h
        end

        def to_zpl
            arr = []
            arr << ZPL::Comment(@name)
            arr << ZPL::FieldPosition(@x, @y)
            arr << ZPL::Font(ZPL::DEFAULT_FONT, @w, @h)
            arr << ZPL::FieldData(@d)
            arr << ZPL::FieldSeperator
            return arr
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
            arr = []
            arr << ZPL::Comment(@name)
            arr << ZPL::Font(@n, @w, @h)
            return arr
        end

        def debug
            super
            puts [@n, @w, @h].inspect
        end
    end
end
