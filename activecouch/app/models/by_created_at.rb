class ByCreatedAt < ActiveCouch::View
  define :for_db => 'pages' do
    with_key 'created_at'
  end
end