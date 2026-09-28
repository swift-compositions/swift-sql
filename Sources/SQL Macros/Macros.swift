public import ISO_9075_Foundation
public import SQL

#if CasePaths
    import CasePaths
#endif

#if CasePaths
    @attached(
        extension,
        conformances: Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        CasePathable,
        CasePathIterable,
        names: named(init(_:)),
        named(init(decoder:))
    )
    @attached(
        member,
        conformances: Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(_$ColumnTypes),
        named(_$ColumnWitness),
        named(Draft),
        named(From),
        named(QueryValue),
        named(Selection),
        named(TableColumns),
        named(_columnWidth),
        named(columns),
        named(schemaName),
        named(tableName),
        named(CodingKeys),
        named(init(from:)),
        named(encode(to:)),
        named(AllCasePaths),
        named(allCasePaths),
        named(_$Element)
    )
    @attached(memberAttribute)
    public macro Table(
        _ name: String = "",
        schema schemaName: String = ""
    ) =
        #externalMacro(
            module: "SQL_Macros_Implementation",
            type: "TableMacro"
        )
#else
    @attached(
        extension,
        conformances: Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(init(_:)),
        named(init(decoder:))
    )
    @attached(
        member,
        conformances: Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(_$ColumnTypes),
        named(_$ColumnWitness),
        named(Draft),
        named(From),
        named(QueryValue),
        named(Selection),
        named(TableColumns),
        named(_columnWidth),
        named(columns),
        named(schemaName),
        named(tableName),
        named(CodingKeys)
    )
    @attached(memberAttribute)
    public macro Table(
        _ name: String = "",
        schema schemaName: String = ""
    ) =
        #externalMacro(
            module: "SQL_Macros_Implementation",
            type: "TableMacro"
        )
#endif

#if CasePaths
    @attached(
        extension,
        conformances: _Selection,
        Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        CasePathable,
        CasePathIterable,
        names: named(init(_:)),
        named(init(decoder:))
    )
    @attached(
        member,
        conformances: _Selection,
        Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(_$ColumnTypes),
        named(_$ColumnWitness),
        named(Draft),
        named(From),
        named(QueryValue),
        named(Selection),
        named(TableColumns),
        named(_columnWidth),
        named(columns),
        named(schemaName),
        named(tableName),
        named(CodingKeys),
        named(init(from:)),
        named(encode(to:)),
        named(AllCasePaths),
        named(allCasePaths),
        named(_$Element)
    )
    @attached(memberAttribute)
    public macro Selection(
        _ name: String = ""
    ) =
        #externalMacro(
            module: "SQL_Macros_Implementation",
            type: "TableMacro"
        )
#else
    @attached(
        extension,
        conformances: _Selection,
        Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(init(_:)),
        named(init(decoder:))
    )
    @attached(
        member,
        conformances: _Selection,
        Table,
        PartialSelectStatement,
        PrimaryKeyedTable,
        names: named(_$ColumnTypes),
        named(_$ColumnWitness),
        named(Draft),
        named(From),
        named(QueryValue),
        named(Selection),
        named(TableColumns),
        named(_columnWidth),
        named(columns),
        named(schemaName),
        named(tableName),
        named(CodingKeys)
    )
    @attached(memberAttribute)
    public macro Selection(
        _ name: String = ""
    ) =
        #externalMacro(
            module: "SQL_Macros_Implementation",
            type: "TableMacro"
        )
#endif

@attached(peer)
public macro Column(
    _ name: String = "",
    as representableType: (any QueryRepresentable.Type)? = nil,
    generated: GeneratedColumnStorage? = nil,
    primaryKey: Bool = false,
    lazyInitializable: Bool? = nil
) =
    #externalMacro(
        module: "SQL_Macros_Implementation",
        type: "ColumnMacro"
    )

@available(*, deprecated, renamed: "Column")
@attached(peer)
public macro Columns(
    as representableType: (any QueryRepresentable.Type)? = nil,
    primaryKey: Bool = false,
    lazyInitializable: Bool? = nil
) =
    #externalMacro(
        module: "SQL_Macros_Implementation",
        type: "ColumnsMacro"
    )

@attached(peer)
public macro Ephemeral() =
    #externalMacro(
        module: "SQL_Macros_Implementation",
        type: "EphemeralMacro"
    )

@freestanding(expression)
public macro bind<QueryValue: QueryBindable>(
    _ queryValue: QueryValue.QueryOutput,
    as queryValueType: QueryValue.Type = QueryValue.self
) -> BindQueryExpression<QueryValue> =
    #externalMacro(module: "SQL_Macros_Implementation", type: "BindMacro")

@freestanding(expression)
public macro sql<QueryValue>(
    _ queryFragment: ISO_9075.Fragment,
    as queryValueType: QueryValue.Type = QueryValue.self
) -> SQLQueryExpression<QueryValue> =
    #externalMacro(module: "SQL_Macros_Implementation", type: "SQLMacro")

@freestanding(expression)
public macro sql(
    _ queryFragment: ISO_9075.Fragment,
    as queryValueType: Any.Type = Any.self
) -> SQLQueryExpression<Any> =
    #externalMacro(module: "SQL_Macros_Implementation", type: "SQLMacro")

@attached(accessor, names: named(get))
public macro _ColumnDefinition() =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnDefinitionMacro")

@attached(accessor, names: named(get))
public macro _PrimaryKeyDefault() =
    #externalMacro(module: "SQL_Macros_Implementation", type: "PrimaryKeyDefaultMacro")

@_documentation(visibility: private)
@attached(accessor, names: named(get))
public macro _ColumnDefault() =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnDefaultMacro")

@attached(
    member,
    names: named(_$ColumnTypes),
    named(_$ColumnWitness),
    named(From),
    named(QueryValue),
    named(Selection),
    named(TableColumns),
    named(_columnWidth),
    named(columns)
)
@attached(
    extension,
    conformances: TableDraft,
    PartialSelectStatement,
    names: named(init(_:)),
    named(init(decoder:))
)
public macro _Draft<T>(_ primaryTable: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "TableMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailJSONMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable & Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: Table>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckGroupMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: Table & Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckGroupMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T>(_ value: T) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable>(_ value: T) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: Table>(_ value: T) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckGroupMacro")

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: RawRepresentable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailRawRepresentableMacro")
where T.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: RawRepresentable & Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailRawRepresentableMacro")
where T.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable & RawRepresentable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")
where T.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable & RawRepresentable & Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")
where T.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: SQL::_OptionalProtocol>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailRawRepresentableMacro")
where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: SQL::_OptionalProtocol & Codable>(_ type: T.Type) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailRawRepresentableMacro")
where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: SQL::_OptionalProtocol & QueryBindable>(
    _ type: T.Type
) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")
where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: SQL::_OptionalProtocol & QueryBindable & Codable>(
    _ type: T.Type
) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")
where T.Wrapped: RawRepresentable, T.Wrapped.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: RawRepresentable>(_ value: T) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckFailRawRepresentableMacro")
where T.RawValue: QueryBindable

@_documentation(visibility: private)
@attached(peer)
public macro ColumnCheck<T: QueryBindable & RawRepresentable>(_ value: T) =
    #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")
where T.RawValue: QueryBindable

#if CasePaths
    @_documentation(visibility: private)
    @attached(peer)
    public macro CaseCheck<T>(_ type: T.Type) =
        #externalMacro(module: "SQL_Macros_Implementation", type: "ColumnCheckPassMacro")

    @_documentation(visibility: private)
    @attached(peer)
    public macro CaseCheck<T: SQL::_OptionalProtocol>(_ type: T.Type) =
        #externalMacro(module: "SQL_Macros_Implementation", type: "CaseCheckFailMacro")
#endif
