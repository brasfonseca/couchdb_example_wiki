class ByPageId < ActiveCouch::View
  define :for_db => 'page_versions' do
    with_key 'page_id'
  end
end