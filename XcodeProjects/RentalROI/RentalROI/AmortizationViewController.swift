//
//  AmortizationViewController.swift
//  RentalROI
//
//  Created by Sean on 9/29/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import UIKit
class AmortizationViewController: UITableViewController {

  var monthlyTerms: NSArray!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return monthlyTerms.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    var cell = tableView.dequeueReusableCellWithIdentifier("aCell") as UITableViewCell!
    var textLabel = cell.textLabel!
    var detailTextLabel = cell.detailTextLabel!
    var pos = indexPath.row
    var monthlyTerm = monthlyTerms[pos] as NSDictionary
    var pmtNo = monthlyTerm["pmtNo"] as Int
    var balance0 = monthlyTerm["balance0"] as Double
    textLabel.text = NSString(format: "%d $%.2f", pmtNo, balance0)
    
    var interest = monthlyTerm["interest"] as Double
    var principal = monthlyTerm["principal"] as Double
    
    var property = RentalProperty.sharedInstance();
    var invested = property.purchasePrice - property.loanAmt + (property.extra * Double(pmtNo))
    var net = property.rent - property.escrow - interest - property.expenses
    var roi = net * 12 / invested
    
    detailTextLabel.text = NSString(format: "Interest: %5.2f  Principal: %5.2f   ROI:%3.2f%%", interest, principal, roi * 100);
    
    return cell
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationItem.title = NSLocalizedString("label_Amortization", comment: "")
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier("MonthlyTerm", sender: indexPath)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var vc = segue.destinationViewController as MonthlyTermViewController
    var row = (sender! as NSIndexPath).row
    vc.monthlyTerm = monthlyTerms[row] as NSDictionary
  }
}
