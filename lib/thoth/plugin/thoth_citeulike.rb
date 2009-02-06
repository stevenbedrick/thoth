#--
# Copyright (c) 2009 Ryan Grove <ryan@wonko.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#   * Neither the name of this project nor the names of its contributors may be
#     used to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#++

require 'cgi'
require 'json'
require 'open-uri'
require 'timeout'
require 'syndication/rss'
require 'syndication/dublincore'


module Thoth; module Plugin

  # Thoth plugin to get the latest CiteULike posts by a specified user. Parses RSS feed- no API yet
  module Citeulike
    
    FEED_URL = 'http://www.citeulike.org/rss/user/'
        
    Configuration.for("thoth_#{Thoth.trait[:mode]}") do
      citeulike {

        # Time in seconds to cache results. Default is 1800 seconds (30
        # minutes).
        cache_ttl 1800 unless Send('respond_to?', :cache_ttl)

        # Request timeout in seconds.
        request_timeout 5 unless Send('respond_to?', :request_timeout)
      }
    end
  
    class << self
      
      def recent_saved_articles(username)
      
          cache   = Ramaze::Cache.value_cache
          request = "#{FEED_URL}/#{::CGI.escape(username)}"

          if value = cache[request]
            return value
          end

          response = []

          parser = Syndication::RSS::Parser.new
          
          Timeout.timeout(Config.delicious.request_timeout, StandardError) do
            response = parser.parse(open(request).readlines.join)
          end

          # Parse the response into a more friendly format.
          data = []

          response.items.each do |item|
            data << {
              :title => item.dc_title,
              :url  => item.link,
              :source => item.dc_source,
              :author => item.dc_creator
            }
          end

          return cache.store(request, data, :ttl => Config.delicious.cache_ttl)

        rescue => e
          Ramaze::Log.error("CiteULike load failed: #{e}")
          return []
        end
        
        
      end
    
      
    end

end; end

