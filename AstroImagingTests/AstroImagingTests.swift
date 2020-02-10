//
//  AstroImagingTests.swift
//  AstroImagingTests
//
//  Created by Don Willems on 08/02/2020.
//  Copyright © 2020 lapsedpacifist. All rights reserved.
//

import XCTest
@testable import AstroImaging

extension NSImage.Name {
     static let stars1 = NSImage.Name("stars1")
     static let red = NSImage.Name("red")
     static let green = NSImage.Name("green")
     static let blue = NSImage.Name("blue")
     static let black = NSImage.Name("black")
     static let white = NSImage.Name("white")
     static let grey = NSImage.Name("grey")
}

class AstroImagingTests: XCTestCase {
    
    let appBundle = Bundle(for: AstroImagingTests.self)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let image = appBundle.image(forResource: .stars1)
        XCTAssertNotNil(image)
        if image != nil {
            let asImages = ASImage.extractChannels(from: image!)
            XCTAssertNotNil(asImages)
            //let nsImage = asImage?.cgImage
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
