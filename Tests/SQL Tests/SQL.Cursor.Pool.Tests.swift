// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

import Pool_Primitives
import SQL
import Synchronization
import Testing

extension `Cursor Tests`.Integration {
    struct Session: ~Copyable {
        var remaining: Int
    }

    @Test
    func `cursor retains a checked out handle through continuation and reuses it on exhaustion`() async throws {
        let dropped = Mutex(0)
        let pool = Pool.Bounded<Session>(
            capacity: 1,
            drop: { _ in dropped.withLock { $0 += 1 } },
            destroy: { _ in }
        )
        try await pool.fill(Session(remaining: 1))

        let handle = try await pool.checkout()
        let cursor = SQL.Cursor<Int>(
            context: handle,
            next: { handle in
                var handle = handle
                guard handle.resource.remaining > 0 else { return .exhausted(handle) }
                let value = handle.resource.remaining
                handle.resource.remaining -= 1
                return .element(value, handle)
            },
            close: { handle in .success(handle) },
            reuse: { handle in _ = await handle.resolve(.reusable(())) },
            invalidate: { handle in _ = await handle.resolve(.invalid(())) },
            abandon: { handle in discard handle }
        )

        let firstAdvance = await cursor.next()
        switch consume firstAdvance {
        case .element(let value, let cursor):
            #expect(value == 1)
            #expect(pool.metrics.outstanding.current == 1)
            let terminalAdvance = await cursor.next()
            switch consume terminalAdvance {
            case .exhausted:
                break
            case .element:
                Issue.record("cursor produced an unexpected second element")
            case .failure(let error):
                Issue.record("cursor failed: \(error)")
            }

        case .exhausted:
            Issue.record("cursor exhausted before producing its element")
        case .failure(let error):
            Issue.record("cursor failed: \(error)")
        }

        #expect(pool.metrics.outstanding.current == 0)
        #expect(dropped.withLock { $0 } == 0)
        var reused = try await pool.checkout()
        let remaining = reused.resource.remaining
        _ = await reused.resolve(.reusable(()))
        #expect(remaining == 0)
        await pool.shutdown()
    }

    @Test
    func `dropping a live cursor takes the handle synchronous invalid path`() async throws {
        let dropped = Mutex(0)
        let pool = Pool.Bounded<Session>(
            capacity: 1,
            drop: { _ in dropped.withLock { $0 += 1 } },
            destroy: { _ in }
        )
        try await pool.fill(Session(remaining: 1))

        let handle = try await pool.checkout()
        let cursor = SQL.Cursor<Int>(
            context: handle,
            next: { handle in .exhausted(handle) },
            close: { handle in .success(handle) },
            reuse: { handle in _ = await handle.resolve(.reusable(())) },
            invalidate: { handle in _ = await handle.resolve(.invalid(())) },
            abandon: { handle in discard handle }
        )
        discard cursor

        #expect(dropped.withLock { $0 } == 1)
        #expect(pool.metrics.outstanding.current == 0)
        #expect(pool.metrics.closed == 1)
        await pool.shutdown()
    }

    @Test
    func `iteration and close failures resolve checked out handles invalid`() async throws {
        let destroyed = Mutex(0)
        let pool = Pool.Bounded<Session>(
            capacity: 2,
            drop: { _ in },
            destroy: { _ in destroyed.withLock { $0 += 1 } }
        )
        try await pool.fill(Session(remaining: 1))
        try await pool.fill(Session(remaining: 1))

        let iterationHandle = try await pool.checkout()
        let iteration = SQL.Cursor<Int>(
            context: iterationHandle,
            next: { handle in .failure(.execution("iteration failed"), handle) },
            close: { handle in .success(handle) },
            reuse: { handle in _ = await handle.resolve(.reusable(())) },
            invalidate: { handle in _ = await handle.resolve(.invalid(())) },
            abandon: { handle in discard handle }
        )
        let iterationAdvance = await iteration.next()
        switch consume iterationAdvance {
        case .failure:
            break
        case .element, .exhausted:
            Issue.record("iteration failure did not terminate the cursor")
        }

        let closeHandle = try await pool.checkout()
        let close = SQL.Cursor<Int>(
            context: closeHandle,
            next: { handle in .exhausted(handle) },
            close: { handle in .failure(.execution("close failed"), handle) },
            reuse: { handle in _ = await handle.resolve(.reusable(())) },
            invalidate: { handle in _ = await handle.resolve(.invalid(())) },
            abandon: { handle in discard handle }
        )
        switch await close.close() {
        case .failure:
            break
        case .success:
            Issue.record("close failure resolved the cursor reusable")
        }

        #expect(destroyed.withLock { $0 } == 2)
        #expect(pool.metrics.outstanding.current == 0)
        await pool.shutdown()
    }

    @Test
    func `cancellation resolves a checked out handle invalid`() async throws {
        let destroyed = Mutex(0)
        let pool = Pool.Bounded<Session>(
            capacity: 1,
            drop: { _ in },
            destroy: { _ in destroyed.withLock { $0 += 1 } }
        )
        try await pool.fill(Session(remaining: 1))

        let cancelled = try await Task {
            let handle = try await pool.checkout()
            let cursor = SQL.Cursor<Int>(
                context: handle,
                next: { handle in .exhausted(handle) },
                close: { handle in .success(handle) },
                reuse: { handle in _ = await handle.resolve(.reusable(())) },
                invalidate: { handle in _ = await handle.resolve(.invalid(())) },
                abandon: { handle in discard handle }
            )
            withUnsafeCurrentTask { $0?.cancel() }
            let advance = await cursor.next()
            switch consume advance {
            case .failure(.cancelled):
                return true
            case .element, .exhausted, .failure:
                return false
            }
        }.value

        #expect(cancelled)
        #expect(destroyed.withLock { $0 } == 1)
        #expect(pool.metrics.outstanding.current == 0)
        await pool.shutdown()
    }
}
