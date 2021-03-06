import Log
import Web
import Fiber
import Blog

async.use(Fiber.self)

async.task {
    do {
        try WebHost(bootstrap: BlogBootstrap()).run()
    } catch {
        Log.critical(String(describing: error))
    }
}

async.loop.run()
