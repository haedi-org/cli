out = []

help_break if opt?(:help)
help_break if $edi_paths.empty? && no_opt?(:headless)
help_break if $json_paths.empty? && opt?(:checklist)

# Display info by default
$opts << "--info" if $opts.empty?

if opt?(:headless)
    $stdout.sync = true
    begin
        until false
            input = STDIN.gets.chomp
            clear_stdin()
            quit_notty() if input == QUIT_COMMAND
            unless input == nil
                $edi_paths = extract_edi_paths(input.words)
                $json_paths = extract_json_paths(input.words)
                $dirs = extract_dirs(input.words)
                $opts = extract_tags(input.words)
                $opts << "--collection" unless $dirs.empty?
                unless $edi_paths.empty? && $dirs.empty?
                    out << process_paths($edi_paths, $json_paths, $dirs)
                    print_out(out)
                    out = []
                end
            end
        end
    rescue => exception
        out += [exception.message, exception.backtrace]
        print_out(out)
        out = []
    end
else
    out = process_paths($edi_paths, $json_paths, $dirs)
    print_out(out)
end
