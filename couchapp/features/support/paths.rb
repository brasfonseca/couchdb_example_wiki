def path_to(page_name)
  case page_name
  
  when /the start page/i
    '/_design/couchapp/_show/new'
  
  # Add more page name => path mappings here
  
  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end