//
//  RentalProperty.swift
//  RentalROI
//
//  Created by Sean on 9/29/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import Foundation

public class RentalProperty {

  var purchasePrice = 0.0;
  var loanAmt = 0.0;
  var interestRate = 5.0;
  var numOfTerms = 30;
  var escrow = 0.0;
  var extra = 0.0;
  var expenses = 0.0;
  var rent = 0.0;
  
  struct MyStatic {
    static let KEY_AMO_SAVED = "KEY_AMO_SAVED";
    static let KEY_PROPERTY = "KEY_PROPERTY";
    private static var _sharedInstance = RentalProperty()
  }

  private init() {
    // Commented Java code ommitted
  }
  
  class func sharedInstance() -> RentalProperty {
    return MyStatic._sharedInstance
  }
  
  private func getAmortizationPersistentKey() -> String {
    var aKey = String(format: "%.2f-%.3f-%d-%.2f-%.2f", self.loanAmt, self.interestRate, self.numOfTerms, self.escrow, self.extra);
    return aKey;
  }
  
  func getSavedAmortization() -> NSArray? {
    var savedKey = retrieveUserdefault(MyStatic.KEY_AMO_SAVED) as String?
    var aKey = self.getAmortizationPersistentKey()
    if let str = savedKey {
      if(str.utf16Count > 0 && str == aKey) {
        var jo = retrieveUserdefault(str) as NSArray?
        return jo
      }
    }
    return nil
  }
  
  func saveAmortization(data: NSArray) -> Bool {
    var aKey = self.getAmortizationPersistentKey()
    saveUserdefault(aKey, forKey: MyStatic.KEY_AMO_SAVED)
    return saveUserdefault(data, forKey: aKey)
  }
  
  func load() -> Bool {
    var data = retrieveUserdefault(MyStatic.KEY_PROPERTY) as NSDictionary?
    if var jo = data {
      self.purchasePrice = jo["purchasePrice"] as Double
      self.loanAmt = jo["loanAmt"] as Double
      self.interestRate = jo["interestRate"] as Double
      self.numOfTerms = jo["numOfTerms"]  as Int
      self.escrow = jo["escrow"] as Double
      self.extra = jo["extra"] as Double
      self.expenses = jo["expenses"] as Double
      self.rent = jo["rent"] as Double
      return true;
      
    } else {
      return false
    }
  }
    
  func save() -> Bool {
    var jo : [NSObject : AnyObject] = [
    "purchasePrice": purchasePrice,
    "loanAmt" : loanAmt,
    "interestRate" : interestRate,
    "numOfTerms" : Double(numOfTerms),
    "escrow" : escrow,
    "extra" : extra,
    "expenses" : expenses,
    "rent" : rent]
    
    return self.saveUserdefault(jo, forKey: MyStatic.KEY_PROPERTY)
  }
  
  let userDefaults = NSUserDefaults.standardUserDefaults()
  private func saveUserdefault(data:AnyObject, forKey:String) -> Bool{
    userDefaults.setObject(data, forKey: forKey)
    return userDefaults.synchronize()
  }
  
  private func retrieveUserdefault(key: String) -> AnyObject? {
    var obj: AnyObject? = userDefaults.objectForKey(key)
    return obj
  }
  
  private func deleteUserDefault(key: String) {
    self.userDefaults.removeObjectForKey(key)
  }

}