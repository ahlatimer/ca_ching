guard 'rspec', :version => 2, :cli => "--color --format documentation" do
  watch(%r{^spec/ca_ching/.+_spec\.rb$})
  watch(%r{^lib/ca_ching/(.+)\.rb$})     { |m| "spec/ca_ching/#{m[1]}_spec.rb" }
  watch(%r{^spec/ca_ching/adapters/.+_spec\.rb$})
  watch(%r{^lib/ca_ching/adapters/(.+)\.rb$})     { |m| "spec/ca_ching/adapters/#{m[1]}_spec.rb" }
  watch(%r{^spec/ca_ching/query/.+_spec\.rb$})
  watch(%r{^lib/ca_ching/query/(.+)\.rb$})     { |m| "spec/ca_ching/query/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
