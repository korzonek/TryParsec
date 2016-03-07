import Result

// Just for avoiding overloads...

infix operator >>-?  { associativity left precedence 100 }
infix operator <|>?  { associativity right precedence 130 }
infix operator <*>?  { associativity left precedence 140 }
infix operator <^>?  { associativity left precedence 140 }

infix operator >>-??  { associativity left precedence 100 }
infix operator <|>??  { associativity right precedence 130 }
infix operator <*>??  { associativity left precedence 140 }
infix operator <^>??  { associativity left precedence 140 }

infix operator <|>!!  { associativity right precedence 130 }
infix operator <*>!!  { associativity left precedence 140 }

// MARK: Function-based Parser (e.g. robrix/Madness)

@inline(__always)
public func pure$<In, Out>(output: Out) -> Parser<In, Out>.Function
{
    return { .Done($0, output) }
}

@inline(__always)
public func >>-? <In, Out1, Out2>(p: Parser<In, Out1>.Function, f: (Out1 -> Parser<In, Out2>.Function)) -> Parser<In, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return f(output)(input2)
        }
    }
}

@inline(__always)
public func <|>? <In, Out>(p: Parser<In, Out>.Function, q: () -> Parser<In, Out>.Function) -> Parser<In, Out>.Function
{
    return { input in
        let reply = p(input)
        switch reply {
            case .Fail:
                return q()(input)
            case .Done:
                return reply
        }
    }
}

@inline(__always)
public func <*>? <In, Out1, Out2>(p: Parser<In, Out1 -> Out2>.Function, q: () -> Parser<In, Out1>.Function) -> Parser<In, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, f):
                switch q()(input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, output3):
                        return .Done(input3, f(output3))
                }
        }
    }
}

@inline(__always)
public func <^>? <In, Out1, Out2>(f: Out1 -> Out2, p: Parser<In, Out1>.Function) -> Parser<In, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return .Done(input2, f(output))
        }
    }
}

@inline(__always)
public func many$<In, Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<In, Out>.Function) -> Parser<In, Outs>.Function
{
    return many1$(p) <|>? { pure$(Outs()) }
}

@inline(__always)
public func many1$<In, Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<In, Out>.Function) -> Parser<In, Outs>.Function
{
    return cons <^>? p <*>? { many$(p) }
}

@inline(__always)
public func satisfy$(predicate: UnicodeScalar -> Bool) -> Parser<String.UnicodeScalarView, UnicodeScalar>.Function
{
    return { input in
        if let (head, tail) = uncons(input) where predicate(head) {
            return .Done(tail, head)
        }
        else {
            return .Fail(input, [], "satisfy")
        }
    }
}

// MARK: Function-based Parser + concrete USV type

@inline(__always)
public func pure$$<Out>(output: Out) -> Parser<String.UnicodeScalarView, Out>.Function
{
    return { .Done($0, output) }
}

@inline(__always)
public func >>-?? <Out1, Out2>(p: Parser<String.UnicodeScalarView, Out1>.Function, f: (Out1 -> Parser<String.UnicodeScalarView, Out2>.Function)) -> Parser<String.UnicodeScalarView, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return f(output)(input2)
        }
    }
}

@inline(__always)
public func <|>?? <Out>(p: Parser<String.UnicodeScalarView, Out>.Function, q: () -> Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Out>.Function
{
    return { input in
        let reply = p(input)
        switch reply {
            case .Fail:
                return q()(input)
            case .Done:
                return reply
        }
    }
}

@inline(__always)
public func <*>?? <Out1, Out2>(p: Parser<String.UnicodeScalarView, Out1 -> Out2>.Function, q: () -> Parser<String.UnicodeScalarView, Out1>.Function) -> Parser<String.UnicodeScalarView, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, f):
                switch q()(input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, output3):
                        return .Done(input3, f(output3))
                }
        }
    }
}

@inline(__always)
public func <^>?? <Out1, Out2>(f: Out1 -> Out2, p: Parser<String.UnicodeScalarView, Out1>.Function) -> Parser<String.UnicodeScalarView, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, output):
                return .Done(input2, f(output))
        }
    }
}

@inline(__always)
public func many$$<Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Outs>.Function
{
    return many1$$(p) <|>?? { pure$$(Outs()) }
}

@inline(__always)
public func many1$$<Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Outs>.Function
{
    return cons <^>?? p <*>?? { many$$(p) }
}

@inline(__always)
public func satisfy$$(predicate: UnicodeScalar -> Bool) -> Parser<String.UnicodeScalarView, UnicodeScalar>.Function
{
    return { input in
        if let (head, tail) = uncons(input) where predicate(head) {
            return .Done(tail, head)
        }
        else {
            return .Fail(input, [], "satisfy")
        }
    }
}

// MARK: Memoize

// https://github.com/robrix/Madness/blob/3eb2f3d9043b75abecf8a7acfcf412eac0bff98a/Madness/Parser.swift#L98-L111

@inline(__always)
private func memoize<T>(f: () -> T) -> () -> T {
    var memoized: T!
    return {
        if memoized == nil {
            memoized = f()
        }
        return memoized
    }
}

@inline(__always)
public func delay<C: RangeReplaceableCollectionType, T>(parser: () -> Parser<C, T>.Function) -> Parser<C, T>.Function {
    let memoized = memoize(parser)
    return { memoized()($0) }
}

/// Strict.
@inline(__always)
public func <|>!! <Out>(p: Parser<String.UnicodeScalarView, Out>.Function, q: Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Out>.Function
{
    return { input in
        let reply = p(input)
        switch reply {
            case .Fail:
                return q(input)
            case .Done:
                return reply
        }
    }
}

/// Strict.
@inline(__always)
public func <*>!! <Out1, Out2>(p: Parser<String.UnicodeScalarView, Out1 -> Out2>.Function, q: Parser<String.UnicodeScalarView, Out1>.Function) -> Parser<String.UnicodeScalarView, Out2>.Function
{
    return { input in
        switch p(input) {
            case let .Fail(input2, labels, message):
                return .Fail(input2, labels, message)
            case let .Done(input2, f):
                switch q(input2) {
                    case let .Fail(input3, labels, message):
                        return .Fail(input3, labels, message)
                    case let .Done(input3, output3):
                        return .Done(input3, f(output3))
                }
        }
    }
}

@inline(__always)
public func many_memo<Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Outs>.Function
{
    return many1_memo(p) <|>!! pure$$(Outs())
}

@inline(__always)
public func many1_memo<Out, Outs: RangeReplaceableCollectionType where Outs.Generator.Element == Out>(p: Parser<String.UnicodeScalarView, Out>.Function) -> Parser<String.UnicodeScalarView, Outs>.Function
{
    return cons <^>?? p <*>!! delay { many_memo(p) }
}
