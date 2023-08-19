import { controller } from "@ui.js";
import API from "../api.js";

const Notebook = ({ use, on }) => {
  console.log("Controller notebook");
  const notes = use.local("notes", []);

  on.mount(async () => {
    const items = await API.listNotes();
    notes.set({ items });
    console.log("NOTES", notes.value);
  });
};

export default controller(Notebook);

// EOF
