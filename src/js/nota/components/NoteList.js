import { controller } from "@ui.js";
import API from "../api.js";

const NoteList = ({ use, on }) => {
  const user = use.input("user", null);
  const items = use.derived(user, async (user) => await API.listNotes());
  use.output("items", items);
};

export default controller(NoteList);

// EOF
