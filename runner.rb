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

File.write(source["file"], Base64.decode64(source["code"]).to_s)

class Tests < Test::Unit::TestCase
 def self.insert(source, test)
   symbol = "Test #{test["name"]}".camelcase.underscore.to_sym
   expected_output = Base64.decode64(test["output"])
   define_method(symbol, proc {
     actual_output, status = Open3.capture2(source["command"], stdin_data: Base64.decode64(test["input"]))
     assert_equal(actual_output, expected_output)
   })
 end
end

results = Test::Unit::TestResult.new

tests.each do |test|
  Tests.insert(source, test)
end

result_names = []

Tests.suite.run(results) do |type, test|
  if type == Test::Unit::TestCase::STARTED_OBJECT
    result_names.push test.method_name
  end
end

result_names.uniq!

failures = results.failures.map{ |test| [test.method_name, test] }.to_h
output = result_names.map do |name|
 obj = {
   success: !failures.keys.include?(name)
 }

 unless obj[:success]
   obj[:error] = failures[name].diff.strip
 end

 [name, obj]
end
File.open('output.json', 'w') { |file| file.write(JSON.pretty_generate(output.to_h)) }
