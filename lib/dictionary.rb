# /un_edifact/
#   edcd/ "composite element specs"           (e.g. EDCD_D97A.json)  
#   eded/ "element list with name/desc/repr"  (e.g. EDED_D97A.json)  
#   edmd/ "message structure"                 (e.g. EDMD_APERAK_D97A)
#   edsd/ "segment specs"                     (e.g. EDSD_D97A.json)
#   uncl/ "coded data reference"              (e.g. UNCL_D00A.json)

class Dictionary
    def initialize(dir = DATA_PATH)
        @dir = dir
        @cache = {
            "un_edifact" => {
                "edcd" => {},
                "eded" => {},
                "edmd" => {},
                "edsd" => {},
                "uncl" => {}
            }
        }
    end

    def debug
        puts segment_specification("LIN", "D97A")
    end

    def coded_data_reference(code, value, version, standard = "un_edifact")
        return {} if (version == nil) or (value == nil)
        data = retrieve_un_edifact_data("UNCL", version)
        return {} if data.dig(code, value) == nil
        return data[code][value]
    end
    
    def element_specification(code, version, standard = "un_edifact")
        return {} if version == nil
        data = retrieve_un_edifact_data("EDED", version)
        return data.key?(code) ? data[code] : {}
    end

    def composite_specification(code, version, standard = "un_edifact")
        return {} if version == nil
        data = retrieve_un_edifact_data("EDCD", version)
        return data.key?(code) ? data[code] : {}
    end

    def segment_specification(tag, version, standard = "un_edifact")
        return {} if version == nil
        data = retrieve_un_edifact_data("EDSD", version)
        return data.key?(tag) ? data[tag] : {}
    end

    def retrieve_un_edifact_data(datatype, version, message = nil)
        # Ensure correct casing on all strings
        datatype, version = datatype.downcase, version.upcase
        message = message.upcase unless message == nil
        # In context of the correct entry in the cache
        @cache["un_edifact"][datatype].tap do |entry|
            # Return cached version if it exists
            key = message.blank? ? version : message + "_" + version
            return entry[key] if entry.key?(key)
            # Otherwise load, store, and return
            path = "/un_edifact/#{datatype}/#{datatype.upcase}_#{key}.json"
            data = load_json(path)
            entry[key] = data
            return data
        end
    end

    def load_json(path)
        path = @dir + path
        # Return no data if path doesn't exist
        return {} unless File.file?(path)
        # Otherwise load in file to JSON data
        file = File.open(path)
        json = JSON.load(file)
        # Close file before returning JSON data
        file.close
        return json
    end
end

$dictionary = Dictionary.new