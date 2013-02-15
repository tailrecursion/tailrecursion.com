module Jekyll
  module Filters
    def author_links(authors)
      site_authors = @context.registers[:site].config['authors']
      authors = authors.map do |author|
        "<a class='author' href='#{site_authors[author]["web"]}'>
          <img style='vertical-align:middle;'
               src='http://www.gravatar.com/avatar/#{site_authors[author]["gravatar"]}?s=20'>
          #{site_authors[author]["display_name"]}
        </a>"
      end.join("&nbsp;")
    end
  end
end

