EMPTY_STRING = ""

class Object
    def is_number?
        # to_f.to_s == to_s || to_i.to_s == to_s
        return Float(self) != nil rescue false
    end

    def blank?
        return true if self == nil
        return true if self == false
        return true if self == ""
        return true if self == " "
        return true if self == []
        return true if self == {}
        return false
    end

    def quote(punc = "\"")
        return self.to_s.encap(punc, punc)
    end
end

class Array
    def tail
        return [] if self.empty?
        return self[1..-1]
    end

    def words
        return self.join(" ")
    end
end

class String
    def titleize(slash = true)
        temp = self.downcase
        # By forward slash
        temp = temp.split(/\//).map { |w| w.weak_titleize }.join("/") if slash
        # By space
        temp = temp.split(/ |\_|\-/).map { |w| w.weak_titleize }.words
        return temp 
    end

    def weak_titleize
        # Don't lowercase letters that are not the first letter of string
        # e.g. abc => Abc, abC => AbC, ABc => ABc, abc def => Abc def
        return self.chars.map.with_index { |l, i| i == 0 ? l.upcase : l }.join
    end

    def first(length = 1)
        return self[0, length]
    end
    
    def key
        return self.gsub(" ", "_").downcase
    end

    def unkey
        return self.gsub("_", " ").titleize
    end

    def lpad(n)
        return self.rjust(n, " ")
    end

    def rpad(n)
        return self.ljust(n, " ")
    end

    def encap(a, b)
        return a + self + b
    end

    def words
        return self.split(" ")
    end

    def flatten
        return self
    end
end

class String
    def xml(str)
        return self.encap("<#{str}>", "</#{str}>")
    end

    def xml_comment
        return self.encap("<!--", "-->")
    end
end

class String
    def html_sanitize
        return self
            .gsub("<", "&lt;")
            .gsub(">", "&gt;")
            .gsub("\"", "&quot;")
    end

    def html(tag, ti: nil, id: nil, cl: nil, st: nil, href: nil,
        colspan: nil, onclick: nil, onmouseover: nil, onmouseleave:nil)
        arr = [
            ["id", id&.quote],
            ["class", cl&.quote],
            ["style", st&.quote],
            ["title", ti&.html_sanitize.quote],
            ["href", href&.quote],
            ["colspan", colspan&.quote],
            ["onclick", onclick&.quote("'")],
            ["onmouseover", onmouseover&.quote("'")],
            ["onmouseleave", onmouseleave&.quote("'")],
        ]
        open_tag = "<" + tag
        for arg, var in arr do
            open_tag += " #{arg}=#{var}" unless var.blank?
        end
        return self.encap(open_tag + ">", tag.encap("</", ">"))
    end
end
    
class String
    def split_with_release(split_char, release_char)
        temp, word, is_released = [], "", false
        self.chars.each_with_index do |char, index|
            if is_released
                word += char
                is_released = false
            elsif char == split_char
                temp << word
                word = ""
            elsif char == release_char
                is_released = true
            elsif index == self.length - 1
                word += char
                temp << word
            else
                word += char
            end
        end
        return temp
    end
end