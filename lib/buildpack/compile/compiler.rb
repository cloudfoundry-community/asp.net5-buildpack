# Encoding: utf-8
# ASP.NET Core Buildpack
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

require_relative 'libuv_installer.rb'
require_relative 'libunwind_installer.rb'
require_relative 'dnvm_installer.rb'
require_relative 'dnx_installer.rb'
require_relative 'dnu.rb'
require_relative '../bp_version.rb'

require 'json'
require 'pathname'

module AspNetCoreBuildpack
  class Compiler
    def initialize(build_dir, cache_dir, libuv_binary, libunwind_binary, dnvm_installer, dnx_installer, dnu, copier, out)
      @build_dir = build_dir
      @cache_dir = cache_dir
      @libuv_binary = libuv_binary
      @libunwind_binary = libunwind_binary
      @dnvm_installer = dnvm_installer
      @dnx_installer = dnx_installer
      @dnu = dnu
      @copier = copier
      @out = out
    end

    def compile
      puts "ASP.NET Core buildpack version: #{BuildpackVersion.new.version}\n"
      puts "ASP.NET Core buildpack starting compile\n"
      step('Restoring files from buildpack cache', method(:restore_cache))
      step('Extracting libuv', method(:extract_libuv))
      step('Extracting libunwind', method(:extract_libunwind))
      step('Installing DNVM', method(:install_dnvm))
      step('Installing DNX with DNVM', method(:install_dnx))
      step('Restoring dependencies with DNU', method(:restore_dependencies))
      step('Saving to buildpack cache', method(:save_cache))
      puts "ASP.NET Core buildpack is done creating the droplet\n"
      return true
    rescue StepFailedError => e
      out.fail(e.message)
      return false
    end

    private

    def extract_libuv(out)
      libuv_binary.extract(File.join(build_dir, 'libuv'), out) unless File.exist? File.join(build_dir, 'libuv')
    end

    def extract_libunwind(out)
      libunwind_binary.extract(File.join(build_dir, 'libunwind'), out) unless File.exist? File.join(build_dir, 'libunwind')
    end

    def restore_cache(out)
      copier.cp(File.join(cache_dir, '.dnx'), build_dir, out) if File.exist? File.join(cache_dir, '.dnx')
      copier.cp(File.join(cache_dir, 'libuv'), build_dir, out) if File.exist? File.join(cache_dir, 'libuv')
      copier.cp(File.join(cache_dir, 'libunwind'), build_dir, out) if File.exist? File.join(cache_dir, 'libunwind')
    end

    def install_dnvm(out)
      dnvm_installer.install(build_dir, out) unless File.exist? File.join(build_dir, 'approot', 'runtimes')
    end

    def install_dnx(out)
      dnx_installer.install(build_dir, out) unless File.exist? File.join(build_dir, 'approot', 'runtimes')
    end

    def restore_dependencies(out)
      dnu.restore(build_dir, out) unless File.exist? File.join(build_dir, 'approot', 'packages')
    end

    def save_cache(out)
      copier.cp(File.join(build_dir, '.dnx'), cache_dir, out) if File.exist? File.join(build_dir, '.dnx')
      copier.cp(File.join(build_dir, 'libuv'), cache_dir, out) unless File.exist? File.join(cache_dir, 'libuv')
      copier.cp(File.join(build_dir, 'libunwind'), cache_dir, out) unless File.exist? File.join(cache_dir, 'libunwind')
    end

    def step(description, method)
      s = out.step(description)
      begin
        method.call(s)
      rescue => e
        s.fail(e.message)
        raise StepFailedError, "#{description} failed, #{e.message}"
      end

      s.succeed
    end

    attr_reader :build_dir
    attr_reader :cache_dir
    attr_reader :libuv_binary
    attr_reader :libunwind_binary
    attr_reader :dnvm_installer
    attr_reader :dnx_installer
    attr_reader :mozroots
    attr_reader :dnu
    attr_reader :copier
    attr_reader :out
  end

  class StepFailedError < StandardError
  end
end
