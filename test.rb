letters = Array.new(26) { |i| (65 + i).chr }

for a, b in letters.repeated_permutation(2) do
    print a + "EDI" + b + "\t"
end