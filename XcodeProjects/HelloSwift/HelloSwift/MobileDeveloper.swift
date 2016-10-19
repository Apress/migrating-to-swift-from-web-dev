//
//  MobileDeveloper.swift
//  HelloSwift
//
//  Created by Sean on 6/28/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import Foundation

class MobileDeveloper {
  var name  = "" // var type is infered by the value
  
  func writeCode(arg: String) -> Void {
    // some dummy implementation
    println("\(self.name) wrote: Hello, \(arg)")
  }
  
  private func doPrivateWork() {
    println(">> doPrivateWork")
  }
}

// another class in the same source file
class TestDriver {
  func testDoPrivateWork() -> Void {
    var developer = MobileDeveloper()
    developer.doPrivateWork()
  }
}
