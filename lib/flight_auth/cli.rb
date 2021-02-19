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

require 'time'
require 'slop'
require 'fileutils'

module FlightAuth
  CLI = Struct.new(:shared_secret_path, :issuer) do
    def slop
      @slop ||= Slop::Options.new do |o|
        o.bool '--secret', 'generate and save a new shared secret'
        o.string '--user', 'sets the username field in the token', default: ENV['USER']
        o.integer '--expiry', 'how long the tokens are valid for in days', default: 1
        o.on '--help', 'display this help' do
          puts o
          exit
        end
      end
    end

    def run(*args)
      # Parse the options
      opts = slop.parse(args)

      # Determine the shared secret
      if opts.secret?
        File.write(shared_secret_path, SecureRandom.alphanumeric(100))
        FileUtils.chmod(0400, shared_secret_path)
      elsif ! File.exists? shared_secret_path
        raise MissingError, <<~ERROR.chomp
          The shared_secret_path does not exists: #{shared_secret_path}
          Please use --secret to generate one!
        ERROR
      end
      shared_secret = File.read shared_secret_path

      # Generate the token
      now = Time.now
      payload = {
        username: opts[:user],
        iss: issuer,
        iat: now.to_i,
        nbf: now.to_i,
        exp: now.to_i + opts[:expiry] * 86400
      }
      puts JWT.encode(payload, shared_secret, 'HS256')
    end

  end
end
