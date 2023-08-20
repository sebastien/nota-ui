class HTTPBridge {
  constructor(prefix) {
    this.prefix = prefix;
  }
  async GET(path) {
    const res = await fetch(`${this.prefix}${path}`);
    if (!res.ok) {
      throw new Error("Request failed");
    }
    const contentType = res.headers.get("Content-Type");

    if (contentType.includes("application/json")) {
      return res.json();
    } else if (contentType.includes("text/html")) {
      return res.text();
    } else {
      return res.text();
    }
  }
}
class APIClient {
  constructor() {
    this.bridge = new HTTPBridge("/api/");
  }
  listNotes() {
    return this.bridge.GET("notes");
  }
  renderNote(note) {
    return this.bridge.GET(`note/${note}.html`);
  }
}

export default new APIClient();
