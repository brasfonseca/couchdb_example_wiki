class ById < ActiveCouch::View
  define :for_db => 'pages' do
    with_key '_id'
  end
end