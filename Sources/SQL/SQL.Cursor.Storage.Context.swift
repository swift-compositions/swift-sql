// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor.Storage {
    /// Type-erased storage for one concrete move-only provider context.
    @usableFromInline
    final class Context<State: ~Copyable>: SQL.Cursor<Element>.Storage {
        @usableFromInline
        var state: State?

        @usableFromInline
        let source: (consuming State) async -> SQL.Cursor<Element>.Advance<State>

        @usableFromInline
        let release: (consuming State) async -> SQL.Cursor<Element>.Close<State>

        @usableFromInline
        let reuse: (consuming State) async -> Void

        @usableFromInline
        let invalidate: (consuming State) async -> Void

        @usableFromInline
        let abandon: (consuming State) -> Void

        @usableFromInline
        init(
            context: consuming sending State,
            next: @escaping (consuming State) async -> SQL.Cursor<Element>.Advance<State>,
            close: @escaping (consuming State) async -> SQL.Cursor<Element>.Close<State>,
            reuse: @escaping (consuming State) async -> Void,
            invalidate: @escaping (consuming State) async -> Void,
            abandon: @escaping (consuming State) -> Void
        ) {
            self.state = context
            self.source = next
            self.release = close
            self.reuse = reuse
            self.invalidate = invalidate
            self.abandon = abandon
        }

        deinit {
            let state = consume self.state
            self.state = nil
            guard let state = consume state else { return }
            abandon(state)
        }
    }
}

extension SQL.Cursor.Storage.Context {
    @usableFromInline
    func take() -> sending State {
        let state = consume self.state
        self.state = nil
        guard let state = consume state else {
            preconditionFailure("SQL.Cursor context consumed more than once")
        }
        return state
    }

    @usableFromInline
    override nonisolated(nonsending)
    func next() async -> SQL.Cursor<Element>.Next {
        let state = take()
        guard Task.isCancelled == false else {
            await invalidate(state)
            return .failure(.cancelled)
        }

        let advance = await source(state)
        switch consume advance {
        case .element(let element, let state):
            guard Task.isCancelled == false else {
                await invalidate(state)
                return .failure(.cancelled)
            }
            self.state = state
            return .element(element, SQL.Cursor(storage: self))

        case .exhausted(let state):
            guard Task.isCancelled == false else {
                await invalidate(state)
                return .failure(.cancelled)
            }
            await reuse(state)
            return .exhausted

        case .failure(let error, let state):
            await invalidate(state)
            return .failure(error)
        }
    }

    @usableFromInline
    override nonisolated(nonsending)
    func close() async -> Result<Void, SQL.Error> {
        let state = take()
        guard Task.isCancelled == false else {
            await invalidate(state)
            return .failure(.cancelled)
        }

        let close = await release(state)
        switch consume close {
        case .success(let state):
            guard Task.isCancelled == false else {
                await invalidate(state)
                return .failure(.cancelled)
            }
            await reuse(state)
            return .success(())

        case .failure(let error, let state):
            await invalidate(state)
            return .failure(error)
        }
    }
}
