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
#   unas/  "UNA segment specs"                (e.g. UNAS.json)

FALLBACK_VERSION = "D97A"
FALLBACK_SERVICE_VERSION = "40000"
DEFAULT_CODE_LIST = "UNCL"
DEFAULT_CODE_LIST_PATH = "/agencies/un_edifact/uncl/UNCL_D20B.json"
DEFAULT_SUBSET = "un_edifact"
DEFAULT_CACHE = {}

AGENCY_CODELIST_MAP = {
#   3055   => [name, path],
    DEFAULT_CODE_LIST => [DEFAULT_CODE_LIST.downcase, DEFAULT_CODE_LIST_PATH],
    "9"    => ["eancom", "/agencies/eancom/cl.json"],
    "10"   => ["odette", "/agencies/odette/cl.json"],
    "20"   => ["bic", "/agencies/bic/cl.json"],
    "166"  => ["nmfca", "/agencies/nmfca/cl.json"],
    "306"  => ["smdg", "/agencies/smdg/cl.json"],
    "321"  => ["edigas", "/agencies/edigas/cl/CL_4.json"],
    "ZEW"  => ["edigas", "/agencies/edigas/cl/CL_4.json"],
    "6346" => ["iso_6346", "/agencies/smdg/iso_6346.json"],
    "IATA" => ["iata", "/agencies/iata/cl.json"],
}

SERVICE_DATATYPES = ["SCL", "SE", "SC", "SS", "UNAS"]

EDIFACT_DATATYPE = {
    "CL" => "UNCL",
    "SCL" => "SCL",
    "ED" => "EDED",
    "SE" => "SE",
    "CD" => "EDCD",
    "SC" => "SC",
    "SD" => "EDSD",
    "SS" => "SS",
    "UNAS" => "UNAS",
    "MD" => "EDMD"
}

class Dictionary
    attr_reader :read_count

    def initialize(dir = DATA_PATH)
        @dir = dir
        @read_count = 0
        @code_lists_used = []
        @cache = DEFAULT_CACHE
    end

    def code_lists_used_count
        return @code_lists_used.length
    end

    def code_lists_used
        list, splits = [], {}
        begin
            @code_lists_used.each do |name, qualifier|
                if qualifier == nil
                    list << name
                else
                    splits[name] = [] unless splits.key?(name)
                    splits[name] << qualifier
                end
            end
            for key, qualifiers in splits do
                if qualifiers.length < 5
                    list << "#{key} #{qualifiers.join(", ")}"
                else
                    list << "#{key} (#{qualifiers.length})"
                end
            end
            return list
        rescue
            return []
        end
    end

    def add_code_list_used(name, qualifier = nil)
        return if name == DEFAULT_CODE_LIST
        @code_lists_used << [name, qualifier]
        @code_lists_used = @code_lists_used.uniq
    end

    def data_list_lookup(name, dir = @dir)
        path = "#{dir}/lists/#{name}.csv"
        return [] unless File.file?(path)
        return File.readlines(path)
    end

    def code_list_lookup(agency, qualifier = nil, code = nil)
        if AGENCY_CODELIST_MAP.key?(agency)
            name, path = AGENCY_CODELIST_MAP[agency]
            data = retrieve_hash(name, path)
            if qualifier == nil
                add_code_list_used(name.unkey.upcase)
                return data
            end
           #puts "AGENCY=#{agency}; QUALIFIER=#{qualifier}; CODE=#{code}"
            unless data.dig(qualifier, code).blank?
                add_code_list_used(name.unkey.upcase, qualifier)
                return data[qualifier][code]
            else
                unless agency == DEFAULT_CODE_LIST
                    code_list_lookup(DEFAULT_CODE_LIST, qualifier, code)
                end
            end
        end
        return {}
    end

    def has_version?(version)
        for datatype in ["uncl", "edcd", "eded"] do
            basename = "#{datatype.upcase}_#{version}"
            path = "/agencies/#{DEFAULT_SUBSET}/#{datatype}/#{basename}.json"
            return false unless File.file?(@dir + path)
        end
        return true
    end

    def is_service_segment?(value, subset = nil)
        subset = DEFAULT_SUBSET if subset.blank?
        subset = DEFAULT_SUBSET if subset == "EDIFICE" # TODO: implement EDIFICE
        subset = DEFAULT_SUBSET if subset == "EANCOM"  # TODO: implement EANCOM
        params = ["service_segments", subset.downcase]
        return retrieve_csv_column(*params).include?(value)
    end

    def is_service_element?(value, subset = nil)
        subset = DEFAULT_SUBSET if subset.blank?
        subset = DEFAULT_SUBSET if subset == "EDIFICE" # TODO: implement EDIFICE
        subset = DEFAULT_SUBSET if subset == "EANCOM"  # TODO: implement EANCOM
        params = ["service_simple_elements", subset.downcase]
        return retrieve_csv_column(*params).include?(value)
    end

    def is_service_composite?(value, subset = nil)
        subset = DEFAULT_SUBSET if subset.blank?
        subset = DEFAULT_SUBSET if subset == "EDIFICE" # TODO: implement EDIFICE
        subset = DEFAULT_SUBSET if subset == "EANCOM"  # TODO: implement EANCOM
        params = ["service_composite_elements", subset.downcase]
        return retrieve_csv_column(*params).include?(value)
    end

    def retrieve_specification_datum(datatype, code, version = nil, 
        subset = nil, message = nil, fallback = nil)
        # Assign default fallback version if given as nil
        if fallback == nil
            if SERVICE_DATATYPES.include?(datatype)
                fallback = FALLBACK_SERVICE_VERSION
            else
                fallback = FALLBACK_VERSION
            end
        end
        # Reassign values if given as nil or default
        version = fallback if version == nil
        subset = DEFAULT_SUBSET if subset == nil
        datatype = EDIFACT_DATATYPE[datatype] if subset == DEFAULT_SUBSET
        # Retrieve EDI data using parameters
        params = [datatype, subset, version, message, fallback]
        data = retrieve_edi_data(*params)
        # Reattempt without subset if no data is found
        if data.blank? && (subset != DEFAULT_SUBSET)
            params = [datatype, code, version, nil, message, nil]
            return retrieve_specification_datum(*params)
        end
        return data if code == nil
        return data.key?(code) ? data[code] : {}
    end

    def coded_data_reference(code, value, version = nil, subset = nil)
        params = ["CL", code, version, subset]
        data = retrieve_specification_datum(*params)
        return data.key?(value) ? data[value] : {}
    end

    def service_coded_data_reference(code, value, version = nil, subset = nil)
        params = ["SCL", code, version, subset]
        data = retrieve_specification_datum(*params)
        return data.key?(value) ? data[value] : {}
    end

    def element_specification(code, version = nil, subset = nil)
        params = ["ED", code, version, subset]
        return retrieve_specification_datum(*params)
    end

    def service_element_specification(code, version = nil, subset = nil)
        params = ["SE", code, version, subset]
        return retrieve_specification_datum(*params)
    end

    def composite_specification(code, version = nil, subset = nil)
        params = ["CD", code, version, subset]
        return retrieve_specification_datum(*params)
    end

    def service_composite_specification(code, version = nil, subset = nil)
        params = ["SC", code, version, subset]
        return retrieve_specification_datum(*params)
    end

    def segment_specification(tag, version, subset = nil)
        params = ["SD", tag, version, subset]
        return retrieve_specification_datum(*params)
    end

    def service_segment_specification(tag, version = nil, subset = nil)
        params = [(tag == 'UNA') ? "UNAS" : "SS", tag, version, subset]
        data = retrieve_specification_datum(*params)
        return data.key?(tag) ? data[tag] : data
    end

    def una_segment_specification(version = nil)
        params = ["UNAS", nil, version]
        data = retrieve_specification_datum(*params)
        return data.key?("UNA") ? data["UNA"] : data
    end

    def message_structure_specification(message, version = nil, subset = nil)
        params = ["MD", nil, version, subset, message]
        return retrieve_specification_datum(*params)
    end
    
    #case subset
    #when "UNICORN"; params = ["MD", "UNICORN", "22", message]
    #when "EDIFICE"; params = ["MD", "EDIFICE", "D10A", message]
    #else; return message_structure_specification(message, version)
    #end

    def retrieve_edi_data(datatype, subset, version, message = nil, 
        fallback_version = nil)
        # TODO: if version given is nil, find fallback version from the 
        #       root directory of the subset (normal and service)
        # Default to fallback_version if version given is nil
        version = fallback_version if version == nil
        return {} if version == nil
        # Ensure correct casing on all strings
        datatype = datatype.downcase
        subset = subset.downcase
        version = version.upcase unless version == nil
        message = message.upcase unless message == nil
       #puts @cache.keys.inspect
       #@cache.keys.each { |key| puts @cache[key].keys.inspect }
        @cache[subset] = {} unless @cache.key?(subset)
        if @cache.dig(subset, datatype).blank?
            @cache[subset][datatype] = {}
        end
        # Return cached version if it exists
        key = message.blank? ? version : message + "_" + version
        if @cache[subset][datatype].key?(key)
           #puts "Returning cache entry"
            return @cache[subset][datatype][key]
        end
        # Otherwise load, store, and return
        basename = "#{datatype.upcase}_#{key}"
        path = "/agencies/#{subset.downcase}/#{datatype}/#{basename}.json"
        data = load_json(path)
        if data.blank? and (version != fallback_version)
            data = retrieve_edi_data(
                datatype, subset, fallback_version, message
            )
        end
        @cache[subset][datatype][key] = data unless data.blank?
        return data
    end

    def retrieve_hash(key, path)
        # Use cached version if it exists (and not only "lists")
        if @cache.key?(key) && (@cache[key].keys != ["lists"])
            return @cache[key]
        end
        # Otherwise load, and store
        data = load_json(path)
        return {} if data == {}
        @cache[key] = data
        return data
    end

    def retrieve_csv_column(file_name, subset = DEFAULT_SUBSET, column = 0)
        # In context of the correct entry in the cache
        @cache[subset] = {} unless @cache.key?(subset)
        @cache[subset]["lists"] = {} if @cache.dig(subset, "lists").blank?
        @cache[subset]["lists"].tap do |entry|
            if entry.key?(file_name)
                csv = entry[file_name]
            else
                # Otherwise load, and store
                path = "#{@dir}/agencies/#{subset}/lists/#{file_name}.csv"
                return [] unless File.file?(path)
                csv = CSV.read(path)
                entry[file_name] = csv
                # Increment dictionary read count
                # puts file_name
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
        file = File.open(path, encoding: "UTF-8")
        json = JSON.load(file)
        # Close file before returning JSON data
        file.close
        # Increment dictionary read count
        @read_count += 1
        return json
    end
end

$dictionary = Dictionary.new