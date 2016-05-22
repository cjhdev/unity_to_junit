# Copyright (c) 2016 Cameron Harper
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Parse test output produced by Unity Test Framework and convert to JUnit format
class UnityToJUnit

    PASS_RESULT = /^(?<file>.*):(?<line>[1-9]+):(?<name>.+):PASS$/
    FAIL_RESULT = /^(?<file>.*):(?<line>[1-9]+):(?<name>.+):FAIL:(?<reason>.+)$/
    SKIP_RESULT = /^(?<file>.*):(?<line>[1-9]+):(?<name>.+):SKIP:(?<reason>.+)$/

    # Prints conversion to stdout
    #
    # @param input [String] name of input file (Unity output format)
    def self.parse(input)

        testCount = 0
        failCount = 0
        skipCount = 0
        
        xml = ""
        result = File.read(input)

        puts result

        result.each_line do |line|

            pass = PASS_RESULT.match(line)
            fail = FAIL_RESULT.match(line)
            skip = SKIP_RESULT.match(line)

            if pass or fail or skip

                testCount.increment

                xml << "<testcase classname=\"#{File.basename(test[:file])}\" name=\"#{test[:name]}\">"

                if fail

                    failCount.increment
                    xml << "    <failure type=\"ASSERT FAILED\">\"#{fail[:reason]}\"</failure>"

                elsif skip

                    skipCount.increment
                    xml << "    <skipped type=\"TEST IGNORED\">\"#{fail[:reason]}\"</failure>"

                end

                xml << "</testcase>"

            end

        end

        if testCount > 0

            puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            puts "<testsuite tests=\"#{testCount}\" failures=\"#{failCount}\" skips=\"#{skipCount}\">"
            puts xml
            puts "</testsuite>"

        else

            raise "file is not a unity output"

        end
        
    end

end

ARGV.each do |arg|

    UnityToJUnit.parse(arg)

end
