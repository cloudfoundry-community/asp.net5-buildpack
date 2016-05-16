# Encoding: utf-8
# ASP.NET 5 Buildpack
# Copyright 2014-2016 the original author or authors.
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

require 'rspec'
require_relative '../../../lib/buildpack.rb'

describe AspNet5Buildpack::DotnetInstaller do
  let(:shell) { double(:shell, env: {}) }
  let(:out) { double(:out) }
  subject(:installer) { AspNet5Buildpack::DotnetInstaller.new(shell) }

  describe '#install' do
    it 'wraps calls to ldconfig so dotnet-install.sh does not complain' do
      expect(shell).to receive(:exec).with(match(/source .*ldconfig_wrapper[.]sh; (.*)/), out)
      installer.install('passed-directory', out)
    end

    it 'installs Dotnet CLI' do
      cmd = %r{(bash -c 'source .*; source <\(curl -sSL https:\/\/.*\/dotnet-install.sh\)')}
      expect(shell).to receive(:exec).with(match(cmd), out)
      installer.install('passed-directory', out)
    end

    it 'sets HOME env variable' do
      allow(shell).to receive(:exec)
      installer.install('passed-directory', out)
      expect(shell.env).to include('HOME' => 'passed-directory')
    end
  end
end