# /un_edifact/
#   lists/ "data csv lists"                   (e.g. service_segments.csv)
#   uncl/  "coded data reference"             (e.g. UNCL_D00A.json)
#   edcd/  "composite element specs"          (e.g. EDCD_D97A.json)  
#   eded/  "element list with name/desc/repr" (e.g. EDED_D97A.json)  
#   edmd/  "message structure"                (e.g. EDMD_APERAK_D97A.json)
#   edsd/  "segment specs"                    (e.g. EDSD_D97A.json)
#   ss/    "service segment specs"            (e.g. SS_40000.json)
#   sc/    "composite service element specs"  (e.g. SC_40000.json)
#   se/    "service element specs"            (e.g. SE_40000.json)

class Dictionary
    attr_reader :read_count

    def initialize(dir = DATA_PATH)
        @dir = dir
        @read_count = 0
        @cache = {
            "un_edifact" => {
                "edcd" => {}, "eded" => {}, "edmd" => {}, "edsd" => {},
                "uncl" => {}, "ss" => {}, "sc" => {}, "se" => {}, "lists" => {}
            }
        }
    end
    
    def debug
        # NOTE: Leave for debug purposes
    end

    def is_service_segment?(value, standard = "un_edifact")
        params = ["service_segments", standard]
        return retrieve_csv_column(*params).include?(value)
    end

    def is_service_element?(value, standard = "un_edifact")
        params = ["service_simple_elements", standard]
        return retrieve_csv_column(*params).include?(value)
    end

    def is_service_composite?(value, standard = "un_edifact")
        params = ["service_composite_elements", standard]
        return retrieve_csv_column(*params).include?(value)
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

    def service_element_specification(code, version = "40000")
        return {} if version == nil
        data = retrieve_un_edifact_data("SE", version)
        return data.key?(code) ? data[code] : {}
    end

    def composite_specification(code, version, standard = "un_edifact")
        return {} if version == nil
        data = retrieve_un_edifact_data("EDCD", version)
        return data.key?(code) ? data[code] : {}
    end

    def service_composite_specification(code, version = "40000")
        return {} if version == nil
        data = retrieve_un_edifact_data("SC", version)
        return data.key?(code) ? data[code] : {}
    end

    def segment_specification(tag, version, standard = "un_edifact")
        return {} if version == nil
        data = retrieve_un_edifact_data("EDSD", version)
        return data.key?(tag) ? data[tag] : {}
    end

    def service_segment_specification(tag, version = "40000")
        return {} if version == nil
        data = retrieve_un_edifact_data("SS", version)
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

    def retrieve_csv_column(file_name, standard = "un_edifact", column = 0)
        # In context of the correct entry in the cache
        @cache[standard]["lists"].tap do |entry|
            if entry.key?(file_name)
                # Use cached version if it exists
                csv = entry[file_name]
            else
                # Otherwise load, and store
                path = "#{@dir}/#{standard}/lists/#{file_name}.csv"
                return [] unless File.file?(path)
                csv = CSV.read(path)
                entry[file_name] = csv
                # Increment dictionary read count
                @read_count += 1
            end
            # Return given column of csv
            return csv.map { |line| line[column] }
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
        # Increment dictionary read count
        @read_count += 1
        return json
    end
end

$dictionary = Dictionary.new