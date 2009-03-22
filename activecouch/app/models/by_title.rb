class ByTitle < ActiveCouch::View
  define :for_db => 'pages' do
    with_key 'title'
  end
end