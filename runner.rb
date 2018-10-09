require 'open3'
require 'json'
require 'base64'
require 'test/unit'
require 'test/unit/testresult'

class String
  def camelcase
    split.map(&:capitalize).join
  end

  def underscore
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
    gsub(/([a-z\d])([A-Z])/, '\1_\2').
    tr('-', '_').
    downcase
  end
end

source = JSON.load(STDIN.read)
tests = source["tests"]

#puts "Source: #{source}"
#puts "tests: #{tests}"

File.write(source["file"], Base64.decode64(source["code"]).to_s)

class Tests < Test::Unit::TestCase
 def self.insert(source, test)
   symbol = "Test #{test["name"]}".camelcase.underscore.to_sym
   expected_output = Base64.decode64(test["output"])
   define_method(symbol, proc {
      actual_output, status = Open3.capture2(source["command"], stdin_data: Base64.decode64(test["input"]))
      
      assert_equal(expected_output, actual_output, "Values do not match")
   })
 end
end

#puts "Pre-results creation"
results = Test::Unit::TestResult.new

#puts "before the tests foreach"
tests.each do |test|
   #puts "inside tests foreach loop"

  Tests.insert(source, test)
end

#puts "Tests object: #{tests}"

result_names = []

#puts "Tests.suite.run(results) #{results}"
Tests.suite.run(results) do |type, test|
   #puts "Results type: #{type} test #{test}"
   if type == Test::Unit::TestCase::STARTED_OBJECT
      #puts "Pushing test method name"
      result_names.push test.method_name
   end
end

#puts "Result_Names #{result_names}"
result_names.uniq!

#puts "Unique Result_Names #{result_names} Now Unique"

failures = results.failures.map{ |test| [test.method_name, test] }.to_h

#puts "results object: #{results}"
#puts "Failures object: #{failures}"

output = result_names.map do |name|
   obj = {
      success: !failures.keys.include?(name)
   }
   #puts "obj value: #{obj}"

   unless obj[:success]
      # Edited the :error section to display the expected and actual values
      obj[:error] = "Expected: #{failures[name].expected} Actual: #{failures[name].actual}"
   end

   # Added :results section for obj object to contain the results line
   obj[:results] = results

   [name, obj]
end

#puts "Output value: #{output}"
#puts "Output hash: #{output.to_h}"

File.open('output.json', 'w') { |file| file.write(JSON.pretty_generate(output.to_h)) }
