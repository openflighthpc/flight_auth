#==============================================================================
# Copyright (C) 2021-present Alces Flight Ltd.
#
# This file is part of FlightAuth.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# FlightAuth is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with FlightAuth. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on FlightAuth, please visit:
# https://github.com/openflighthpc/flight_auth
#==============================================================================
require_relative 'lib/flight_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "flight_auth"
  spec.version       = FlightAuth::VERSION
  spec.authors       = ["Alces Flight Ltd"]
  spec.email         = ["flight@openflighthpc.org"]

  spec.summary       = "JWT authentication library for flight applications"
  spec.license       = 'EPL-2.0'
  spec.homepage      = "https://github.com/openflighthpc/flight_auth"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/openflighthpc/flight_auth"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'jwt', '~> 2.2'
  spec.add_runtime_dependency 'slop', '~> 4.8'
end
