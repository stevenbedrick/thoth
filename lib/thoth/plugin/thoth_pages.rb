module Thoth; module Plugin

  # Thoth plugin to get the current site's pages
  module Pages
    Configuration.for("thoth_#{Thoth.trait[:mode]}") do
      pages {
        # nothing here for now...
      }
    end
  
    class << self
      
      def list_of_pages
      
        return Page.all
        
      end
    end
      
    end

end; end