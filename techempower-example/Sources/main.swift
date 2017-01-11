import Log
import Dispatch
import AsyncFiber
import HTTPServer
import Foundation

Log.disabled = true

let coresCount = sysconf(Int32(_SC_NPROCESSORS_ONLN))

func startServer() throws {
    let server = try Server(host: "127.0.0.1", port: 8080, async: AsyncFiber())

    server.route(get: "/plaintext") {
        return "Hello, World!"
    }

    server.route(get: "/json") {
        return ["message": "Hello, World!"]
    }

    try server.start()
}

#if os(Linux)
for _ in 0..<coresCount-1 {
    Thread {
        do {
            try startServer()
        } catch {
            print(error)
        }
    }.start()
}
#endif

try startServer()
