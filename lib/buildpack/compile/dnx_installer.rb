# Encoding: utf-8
# ASP.NET Core Buildpack
# Copyright 2015-2016 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'dnx_version'

module AspNetCoreBuildpack
  class DnxInstaller
    def initialize(shell)
      @shell = shell
    end

    def install(dir, out)
      @shell.env['HOME'] = dir
      version = DnxVersion.new.version(dir, out)
      @shell.exec("bash -c 'source #{dir}/.dnx/dnvm/dnvm.sh; dnvm install #{version} -p -r coreclr'", out)
    end
  end
end
