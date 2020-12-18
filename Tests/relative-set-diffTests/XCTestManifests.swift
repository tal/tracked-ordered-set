import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(relative_set_diffTests.allTests),
    ]
}
#endif
