import { controller } from "@ui.js";
import API from "../api.js";

const NoteView = ({ use, on }) => {
  // const {note} = use.inputs;
  const note = use.input("note", "rap");
  const html = use.derived(note, async (note) => await API.renderNote(note));
  // use.outputs({html})
  use.output("html", html);

  on.NoteInput((event) => {
    note.set(event.target.value);
  });
};

export default controller(NoteView);

// EOF
