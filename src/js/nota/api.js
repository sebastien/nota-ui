class HTTPBridge {
  constructor(prefix) {
    this.prefix = prefix;
  }
  GET(path) {
    return fetch(`${this.prefix}${path}`).then((_) => _.json());
  }
}
class APIClient {
  constructor() {
    this.bridge = new HTTPBridge("/api/");
  }
  listNotes() {
    return this.bridge.GET("notes");
  }
}

export default new APIClient();
