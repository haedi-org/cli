$VERBOSE = nil

require 'rspec'
require_relative '../lib/include.rb'

GSIN_TESTS = [
    ["08012349999999997", true],
    ["73655661561900123", true],
]

SSCC_TESTS = [
    ["106141410073490007", true],
    ["106141410064241540", false],
    ["106141410045645565", true],
]

GTIN_14_TESTS = [
    ["20811234004566", true],
    ["20811234007871", true],
    ["40811234007448", true],
    ["30811234001234", true],
    ["30811234009872", true],
    ["30811234008523", true],
    ["70811234004165", true],
    ["70811234004868", true],
    ["70811234001539", true],
]

VIN_TESTS = [
    ["1FTRX12V69FA11242", true],
    ["4T1BE32K85U528911", true],
    ["JTMWF4DV8C5047998", true],
]

ISBN_TESTS = [
    ["9781861972712", true],
    ["043942089X", true],
    ["0198526636", true],
    ["978-1-56619-909-4", true],
    ["1-56619-909-3", true],
]

ISSN_TESTS = [
    ["2049-3630", true],
    ["0317-8471", true],
    ["0-952-8091", true],
    ["0718-1876", true],
    ["1857-7881", true],
]

ISMN_TESTS = [
    ["M230671187", true],
    ["979-0-0601-1561-5", true],
    ["979 0 3452 4680 5", true],
    ["9790060115615", true],
    ["979-0-9016791-7-7", true],
]

ISO_6346_TESTS = [
    ["CSQU3054383", true],
    ["TOLU4734787", true],
]

RSpec.describe("haedi datatypes") do

    describe("GSIN") do
        GSIN_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_gsin?).to(be(bool))
            end
        end
    end

    describe("SSCC (GTIN-18)") do
        SSCC_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_sscc?).to(be(bool))
            end
        end
    end

    describe("GTIN-14") do
        GTIN_14_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_gtin_14?).to(be(bool))
            end
        end
    end

    describe("VIN") do
        VIN_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_vin?).to(be(bool))
            end
        end
    end

    describe("ISBN") do
        ISBN_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_isbn?).to(be(bool))
            end
        end
    end

    describe("ISSN") do
        ISSN_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_issn?).to(be(bool))
            end
        end
    end

    describe("ISMN") do
        ISMN_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_ismn?).to(be(bool))
            end
        end
    end

    describe("ISO 6346") do
        ISO_6346_TESTS.each do |code, bool|
            it("identifies '#{code}' as #{bool}") do
                expect(code.is_iso_6346?).to(be(bool))
            end
        end
    end

end