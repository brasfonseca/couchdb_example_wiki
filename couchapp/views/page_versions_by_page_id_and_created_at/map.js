function(doc) {
  if(doc.type == 'PageVersion') {
    emit([doc.page_id, doc.created_at], null);
  }
}