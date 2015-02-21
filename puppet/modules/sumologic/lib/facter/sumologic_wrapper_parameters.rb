require 'facter'

Facter.add(:sumologic_wrapper_parameters) do
  setcode do
    # Generates the wrapper.app.parameter for wrapper.conf
    # Assumes that the following are unchanged:
    #   wrapper.app.parameter.1=com.sumologic.scala.collector.Collector
    #   wrapper.app.parameter.2=-b

    sumo_app_params = [
      '/etc/sumologic/sources.json',
      '--clobber',
      '-o',
      '--disableUpgrade',
      '--disableScriptSource',
      '--disableActionSource',
      '-n', $hostname
    ]

    # Check and add the sumologic token that is stored in the .netrc
    sumo_app_params.concat(['-i', username, '-k', password])

    # If testing stage set ephemeral flag so the collector will be deleted automatically after being offline for 12 hours
    sumo_app_params.push('--ephemeral')

    # Convert the sumo_app_params to a string for use in the template
    sumo_app_params_string = ''
    sumo_app_params.each_with_index do |x, idx|
      sumo_app_params_string << "wrapper.app.parameter.#{idx + 3}=#{x}\n"
    end

    sumo_app_params_string
  end
end
