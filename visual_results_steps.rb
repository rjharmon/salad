# He/she/I/it should ... (abbreviated "I" below)
# I should see an 'a.nice' element
# I should see an 'a.nice' element 'My Label'
# I should see an 'a.nice' element with 'My Label'
# I should see a 'p.nice' element with 'My Content'
# I should see 6 'p.nice' elements
# I should see 6 'p.nice' elements with 'My content'

Then /^\w+ should see (\w+) '([^\']*)' element[s]? (?:with (['\/])(.*?)['\/])?/ do |number, el_type, quote_type, contents|
  response.should_not be_redirect
  require 'nokogiri'
  doc = Nokogiri::HTML.parse( response.body )

  
  if quote_type == "/"
    contents = Regexp.new( contents )
  end
  
  if( number =~ /^a[n]?$/ )
    number = 1
  elsif( number =~ /^[0-9]+$/ )
    number = number.to_i
  else
    "#{number}".should == "'a' or 'an' or a number of elements to expect"
  end
  found = 0
  doc.search( el_type ).each do |el_found|
    el = el_found.content
    if( contents )
      if( Regexp === contents)
        if el =~ contents
          found += 1
        end
      elsif( String === contents)
        if el == contents
          found += 1
        end
      elsif( Array === contents)
        if el == contents.shift
          found += 1
        end
      end
    else
      found += 1
    end
  end
  unless found == number
    "#{found} found".should == "#{number} #{el_type} elements"+ ( contents ? " matching #{contents}" : "")
  end  
end

Then /^\w+ should( not)? see (\w+) links? (?:'(.*)' )?to (.*)/ do |nott, number, label, dest|
  response.should_not be_redirect
  if( number =~ /^a[n]?$/ )
    number = 1
  elsif( number =~ /^[0-9]+$/ )
    number = number.to_i
  else
    "#{number}".should == "'a' or 'an' or a number of elements to expect"
  end
  if nott and number > 1
    "should not see #{number} link(s)".should == "either an expected plural link count or 'not', but not both"
  end
  require 'nokogiri'
  doc = Nokogiri::HTML.parse( response.body )
  found = 0
  path = grok_path(dest)
  regex = ( Regexp === path )
  
  messages = ""
  bad_ones = ""
  doc.search( "a" ).each do |link|
    matched_path = false
    matched_label = false
    href = link.attributes["href"].to_s
#    puts "matching #{href} with #{path}"
    if regex ? ( href =~ path ) : ( href == path )
#      puts("MATCHED")
      matched_path = true
    end
    if label and link.content == label
      matched_label = true
    end
    if ( label and matched_path and matched_label )
      found += 1
    elsif( !label and matched_path )
      found += 1
    elsif matched_path and label
      messages += "Found one with matching path and label '#{link.content}'; "
    elsif matched_label
      messages += "Found one with matching label, to #{href}; "
    else
      bad_ones += "Found one with '#{link.content}' to '#{href}'; "
    end
  end
  
  desc = "link(s) with " + ( label ? "label '#{label}' to " : "") +"path "+ ( regex ? "matching #{path}" : path )
  if nott
    if found > 0
      "#{found}".should == "not to receive any #{desc}"
    end
  else
    if found < number
      "#{found}\n#{messages || bad_ones }".should == "#{number} #{desc}"
    elsif found > number
      "#{found}\n#{messages || bad_ones }".should == "#{number} #{desc}"
    end
  end
end

Then /^\w+ should see an outbound link to the (.*) domain$/ do |domain|
  response.should_not be_redirect
  require 'nokogiri'
  doc = Nokogiri::HTML.parse( response.body )

  found = 0
  doc.search("a").each do |link|
    href = link.attributes["href"].to_s or next
    href.sub!(/http:\/\/([^\/])/, '\1')
    if href == domain
      found += 1
    end
    unless found
      "none".should == "a link to the #{domain} domain"
    end
  end
end



