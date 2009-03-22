function(doc) {
  if(doc.type == 'Page' && doc.created_at) {
    emit(doc.created_at, null);
  }
}