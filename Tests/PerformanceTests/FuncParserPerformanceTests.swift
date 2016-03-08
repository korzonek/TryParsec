import XCTest
import Nimble
import TryParsec

private var _testString = ""
private let _testStringCount = 1000

class FuncParserPerformanceTests: XCTestCase
{
    override class func setUp()
    {
        super.setUp()
        for _ in 1..._testStringCount {
            _testString.appendContentsOf("z")
        }
    }

    func test_parser_as_struct()
    {
        let p: Parser<USV, USV> = many(satisfy { $0 == "z" })
        let r = parse(p, _testString.unicodeScalars)._done
        expect(r?.input) == ""
        expect(r?.output.count) == _testStringCount

        self.measureBlock {
            let r = parse(p, _testString.unicodeScalars)
        }
    }

    func test_parser_as_func()
    {
        let p: Parser<USV, USV>.Function = many$(satisfy$ { $0 == "z" })
        let r = p(_testString.unicodeScalars)._done
        expect(r?.input) == ""
        expect(r?.output.count) == _testStringCount

        self.measureBlock {
            let r = p(_testString.unicodeScalars)
        }
    }

    func test_parser_as_func_noGenericsForInput()
    {
        let p: Parser<USV, USV>.Function = many$$(satisfy$$ { $0 == "z" })
        let r = p(_testString.unicodeScalars)._done
        expect(r?.input) == ""
        expect(r?.output.count) == _testStringCount

        self.measureBlock {
            let r = p(_testString.unicodeScalars)
        }
    }

    func test_parser_as_func_noGenericsForInput_memo()
    {
        let p: Parser<USV, USV>.Function = many_memo(satisfy$$ { $0 == "z" })
        let r = p(_testString.unicodeScalars)._done
        expect(r?.input) == ""
        expect(r?.output.count) == _testStringCount

        self.measureBlock {
            p(_testString.unicodeScalars)
        }
    }

    // blazing fast!!!
    // https://swiftjp.slack.com/files/norio_nomura/F0R358350/_________test_parser_as_func_usv_________________.diff
    func test_parser_as_func_noGeneri cs()
    {
        let p: Parser<USV, USV>.Function = many$$$(satisfy$$ { $0 == "z" })
        let r = p(_testString.unicodeScalars)._done
        expect(r?.input) == ""
        expect(r?.output.count) == _testStringCount

        self.measureBlock {
            let r = p(_testString.unicodeScalars)
        }
    }

}
