Wiki.Models.Page = {
  init: function(attributes) {
    this._id = attributes._id;
    this._rev = attributes._rev;
    this.body = attributes.body;
    this.body_was = attributes.body;
    this.created_at = attributes.created_at || Date();
    return this;
  },
  errors: [],
  valid: function() {
    this.errors = [];
    if(this._id.length == 0) {
      this.errors.push("Title can't be blank");
    }
    if(this.body.length == 0) {
      this.errors.push("Body can't be blank");
    }
    return this.errors.length == 0;
  },
  to_json: function() {
    return {
      body: this.body,
      created_at: this.created_at,
      type: 'Page',
      _id: this._id,
      _rev: this._rev
    }
  },
  after_update: function(db) {
    db.saveDoc({
      type: 'PageVersion',
      created_at: Date(),
      body: this.body_was,
      title: this._id,
      page_id: this._id
    })
  }
};
