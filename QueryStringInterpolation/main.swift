import Foundation

typealias SQLValue = String

struct QueryPart {
    var sql: String
    var values: [SQLValue]
}

struct Query<A> {
    let query: QueryPart
    let parse: ([SQLValue]) -> A
    
    init(_ part: QueryPart, parse: @escaping ([SQLValue]) -> A) {
        self.query = part
        self.parse = parse
    }
}

extension QueryPart: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.sql = value
        self.values = []
    }
}

extension QueryPart: ExpressibleByStringInterpolation {
    typealias StringInterpolation = QueryPart
    
    init(stringInterpolation: QueryPart) {
        self.sql = stringInterpolation.sql
        self.values = stringInterpolation.values
    }
}

extension QueryPart: StringInterpolationProtocol {
    init(literalCapacity: Int, interpolationCount: Int) {
        self.sql = ""
        self.values = []
    }
    
    mutating func appendLiteral(_ literal: String) {
        sql += literal
    }
    
    mutating func appendInterpolation(param value: SQLValue) {
        sql += "$\(values.count + 1)"
        values.append(value)
    }
    
    mutating func appendInterpolation(raw value: String) {
        sql += value
    }
}

let id = "1234"
let email = "mail@objc.io"
let tableName = "users"
let sample = Query<String>("SELECT * FROM \(raw: tableName) WHERE id=\(param: id) AND email=\(param: email)", parse: { $0[0] })

assert(sample.query.sql == "SELECT * FROM users WHERE id=$1 AND email=$2")
assert(sample.query.values == [id, email])
dump(sample)
