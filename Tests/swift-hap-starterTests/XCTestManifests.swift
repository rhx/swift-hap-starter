import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swift_hap_starterTests.allTests),
    ]
}
#endif