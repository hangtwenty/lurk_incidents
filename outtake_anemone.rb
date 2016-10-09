require 'rubygems'
require 'mechanize'
require 'anemone'

url = 'https://status.shopify.com/history' # TODO make this come in from commandline (docopt)
if !url.end_with?('history')
    puts 'your target URL should be the full incident history, are you sure it is?'
end

Anemone.crawl(url) do |anenome|
    anenome.focus_crawl { |page| 
        page.links.select { |link| 
            link.path.start_with?('/incidents') 
        }
    }
    anenome.on_every_page { |page|
        puts page.doc.at('title').inner_html
        puts page.doc.at('title')
        #rescue nil
    }
end

