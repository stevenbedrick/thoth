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

module Ramaze
  module Helper
    module Timeago
      
      # timeago algorithm shamelessly adapted 
      # from http://www.actsasflinn.com/2007/04/10/time-ago-method-for-ruby-on-rails
      #
      # options
      # :start_date, sets the time to measure against, defaults to now
      # :later, changes the adjective and measures time forward
      # :round, sets the unit of measure 1 = seconds, 2 = minutes, 3 hours, 4 days, 5 weeks, 6 months, 7 years (yuck!)
      # :max_seconds, sets the maximimum practical number of seconds before just referring to the actual time- defaults to about 1 year
      # :date_format, in standard Time.strftime format.
      
      def timeago(original, options={})
    
        start_date = options.delete(:start_date) || Time.now
        later = options.delete(:later) || false
        round = options.delete(:round) || 5
        max_seconds = options.delete(:max_seconds) || 32556926 # ~ a year
        date_format = options.delete(:date_format) || "%m/%d/%Y %H:%M"
    
        # array of time periods
        chunks = [
          [60 * 60 * 24 * 365, "year"],
          [60 * 60 * 24 * 30, "month"],
          [60 * 60 * 24 * 7, "week"],
          [60 * 60 * 24, "day"],
          [60 * 60, "hour"],
          [60, "minute"],
          [1, "second"]
        ]
    
        if later
          since = original.to_i - start_date.to_i
        else
          since = start_date.to_i - original.to_i
        end
        time = []
    
        if since < max_seconds
          # loop through chunks:
          totaltime = 0
      
          for chunk in chunks[0..round]
            seconds = chunk[0]
            name = chunk[1]
        
            count = ((since - totaltime) / seconds).floor
            time << "#{count} #{name}" unless count == 0
        
            totaltime += count * seconds
          end
      
          if time.empty?
            "less than a #{chunks[round-1][1]} ago"
          else
            "#{time.join(', ')} #{later ? 'later' : 'ago'}"
          end
        else
          original.strftime(date_format)
        end
    
      end
  
  
    end
  end
end
