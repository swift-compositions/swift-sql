// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// ===----------------------------------------------------------------------===//

extension SQL.Cursor {
    actor Storage {
        private let source: @Sendable () async throws(SQL.Error) -> Element?
        private let release: @Sendable () async -> Void
        private var isTerminal = false

        init(
            next: @escaping @Sendable () async throws(SQL.Error) -> Element?,
            close: @escaping @Sendable () async -> Void
        ) {
            source = next
            release = close
        }

        func next() async throws(SQL.Error) -> Element? {
            if isTerminal { return nil }
            if Task.isCancelled {
                await close()
                throw SQL.Error.cancelled
            }

            do throws(SQL.Error) {
                return try await withTaskCancellationHandler(operation: {
                    guard let element = try await source() else {
                        await close()
                        return nil
                    }
                    if Task.isCancelled {
                        await close()
                        throw SQL.Error.cancelled
                    }
                    return element
                }, onCancel: {
                    Task { await self.close() }
                })
            } catch {
                await close()
                throw error
            }
        }

        func close() async {
            guard !isTerminal else { return }
            isTerminal = true
            await release()
        }
    }
}
