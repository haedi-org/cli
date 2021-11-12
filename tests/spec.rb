require 'rspec'
require_relative '../lib/include.rb'

TEST_PATHS = [
    "./tests/data/INVOIC_D93A.edi",
    "./tests/data/DESADV_D01B.edi",
    "./tests/data/INVOIC_D97A.edi",
    "./tests/data/DESADV_D96A.edi",
]

RSpec.describe("Haedi CLI") do
    let!(:test_a) { Document.new(File.readlines(TEST_PATHS[0])) }
    let!(:test_b) { Document.new(File.readlines(TEST_PATHS[1])) }
    let!(:test_c) { Document.new(File.readlines(TEST_PATHS[2])) }
    let!(:test_d) { Document.new(File.readlines(TEST_PATHS[3])) }

    describe(Document) do
        it("identifies segment terminator without UNA segment") do
            expect(test_a.chars.segment_terminator).to(eq('\''))
        end

        it("identifies segment terminator with UNA segment") do
            expect(test_b.chars.segment_terminator).to(eq('\''))
        end

        it("identifies message type of INVOIC document") do
            expect(test_a.message_type).to(eq('INVOIC'))
        end

        it("identifies message type of DESADV document") do
            expect(test_b.message_type).to(eq('DESADV'))
        end

        it("identifies version key of D93A document") do
            expect(test_a.version).to(eq('D93A'))
        end

        it("identifies version key of D01B document") do
            expect(test_b.version).to(eq('D01B'))
        end

        it("identifies document as not being an EANCOM document") do
            expect(test_a.is_eancom?).to(be(false))
        end

        it("identifies document as being an EANCOM document") do
            expect(test_d.is_eancom?).to(be(true))
        end
    end

    describe(Segment) do
        it("formats and identifies the date/time on a DTM segment") do
            result = []
            for segment in test_c.segments do
                if segment.is_a?(DTMSegment)
                    result << segment.date_time.data_name
                end
            end
            expect(result).to(eq(['15/05/2006']))
        end
    end
end