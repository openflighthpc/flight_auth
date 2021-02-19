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
require "flight_auth/version"

module FlightAuth
  class Error < StandardError; end
  class MissingError < Error; end

  Builder = Struct.new(:shared_secret_path) do
    def shared_secret
      @shared_secret ||= if File.exists?(shared_secret_path)
        File.read(shared_secret_path)
      else
        raise MissingError, "The shared secret file does not exist: #{shared_secret_path}"
      end
    end

    def decode(cookie, authorization_header)
      if cookie
        Decoder.new(shared_secret, cookie)
      elsif match = /\ABearer (.*)\Z/.match(authorization_header || '')
        Decoder.new(shared_secret, match[1])
      else
        Decoder.new(shared_secret, '')
      end
    end
  end

  Decoder = Struct.new(:shared_secret, :encoded) do
    def valid?
      !decoded[:invalid]
    end

    def forbidden?
      decoded[:forbidden]
    end

    def username
      decoded['username']
    end

    private

    def decoded
      @decoded ||= begin
        JWT.decode(
          encoded,
          shared_secret,
          true,
          { algorithm: 'HS256' },
        ).first.tap do |hash|
          unless hash['username']
            hash[:invalid] = true
            hash[:forbidden] = true
          end
        end
      rescue JWT::VerificationError
        { invalid: true, forbidden: true }
      rescue JWT::DecodeError
        { invalid: true }
      end
    end
  end
end
