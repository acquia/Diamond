module RSpec::Puppet
  class Coverage
    class << self
      extend Forwardable
      def_delegators :instance, :add, :codecoverage_report!
    end

    def codecoverage_report!
      report = {}

      report[:total] = @collection.size
      report[:touched] = @collection.count { |_, resource| resource.touched? }
      report[:untouched] = report[:total] - report[:touched]
      report[:coverage] = format('%5.2f', ((report[:touched].to_f / report[:total].to_f) * 100))

      report[:detailed] = Hash[*@collection.map do |name, wrapper|
        [name, wrapper.to_hash]
      end.flatten]

      puts <<-EOH.gsub(/^ {8}/, '')
        Total resources:   #{report[:total]}
        Touched resources: #{report[:touched]}
        Resource coverage: #{report[:coverage]}%
      EOH

      if report[:coverage] != '100.00'
        puts <<-EOH.gsub(/^ {10}/, '')
          Untouched resources:
          #{
            untouched_resources = report[:detailed].reject do |_, rsrc|
              rsrc['touched']
            end
            untouched_resources.inject([]) do |memo, (name, _)|
              memo << "  #{name}"
            end.sort.join("\n")
          }
        EOH

        fail 'Coverage not at 100%'
      end
    end
  end
end

at_exit { RSpec::Puppet::Coverage.codecoverage_report! }
