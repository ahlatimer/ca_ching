guard 'rspec', :version => 2, :cli => "--color --format documentation" do
  watch(%r{^spec/ca_ching/.+_spec\.rb$})
  watch(%r{^lib/ca_ching/(.+)\.rb$})     { |m| "spec/ca_ching/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
