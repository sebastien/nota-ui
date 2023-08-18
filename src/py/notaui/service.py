from extra import Service, HTTPRequest, HTTPResponse, on, run as webrun
from extra.services.files import FileService
from pathlib import Path
from nota.operations import LocalOperator, LocalStore
import texto


class NotesService(Service):
    PREFIX = "/api/notes"

    def init(self):
        self.notes: LocalOperator = LocalOperator(LocalStore(Path("data/notes")))

    @on(GET="")
    def listNotes(self, request: HTTPRequest) -> HTTPResponse:
        return request.returns(self.notes.listNotes())

    @on(GET="/{path:rest}/{start:int}:{end:int}")
    def getNoteRange(
        self, request: HTTPRequest, path: str, start: int, end: int
    ) -> HTTPResponse:
        print(start, end, type(start))
        if not self.notes.hasNote(path):
            return request.notFound()
        else:
            return request.returns(self.notes.readFragment(path, start, end))

    @on(GET="/{path:rest}.html")
    def getNoteHTML(self, request: HTTPRequest, path: str) -> HTTPResponse:
        if not self.notes.hasNote(path):
            return request.notFound()
        else:
            parsed = texto.parse(self.notes.readNote(path), offsets=True)
            return request.respond(texto.render(parsed), b"text/html")

    @on(GET="/{path:rest}.nd")
    def getNoteSource(self, request: HTTPRequest, path: str) -> HTTPResponse:
        print("PATH", path)
        if not self.notes.hasNote(path):
            return request.notFound()
        else:
            return request.returns(self.notes.readNote(path))


class Server(Service):
    @on(GET="/api/stats")
    def stats(self, request: HTTPRequest) -> HTTPResponse:
        return request.returns({"storage.page": "pouet"})


def run():
    return webrun(FileService(Path(".")), NotesService(), Server())


if __name__ == "__main__":
    run()


# EOF
