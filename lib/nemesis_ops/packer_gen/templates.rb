# Copyright 2014 Acquia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module NemesisOps::PackerGen
  module Templates
    # Require any available templates
    Dir.glob("#{File.absolute_path(File.dirname(__FILE__))}/templates/*.rb").each do |f|
      require f
    end

    class TemplateNameError < NameError; end

    def self.template_class(name)
      # Camel case the string to match with the template class names
      template_name = Nemesis::Utils.camelcase(name)
      template_klazz = PackerGen::PackerGen::Templates.const_get(template_name)
      template_klazz
    rescue NameError
      raise TemplateNameError, "Unable to find template: #{name}"
    end
  end
end
