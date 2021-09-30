class CTA < Line
    def initialize(data, line_no, version, chars)
        super(data, line_no, version, chars)
        # Push to elements
        push_elements([
            # (3139) Contact function, coded
            @contact_function = define([1, 0], "3139", true),
            # (3413) Department or employee identification
            @department_id = define([2, 0], "3413"),
            # (3412) Department or employee
            @department = define([2, 1], "3412")
        ])
    end
end