function(doc) {
    if(doc.type == 'Page') {
      var words = doc.body.split(/\W/);
      words.forEach(function(word) {
        if (word.length > 0) emit(word, 1);
      });
    }
  }