//
//  RentalPropertyViewFragment.swift
//  RentalROI
//
//  Created by Sean on 9/29/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import UIKit

class RentalPropertyViewController : UITableViewController, EditTextViewControllerDelegate  {
  
  // define constants
  struct MyStatic {
    private static let URL_service_tmpl = "http://www.pdachoice.com/ras/service/amortization?loan=%.2f&rate=%.3f&terms=%d&extra=%.2f&escrow=%.2f"
    private static let KEY_DATA = "data"
    private static let KEY_RC = "rc"
    private static let KEY_ERROR = "error"
  }
  
  var _property = RentalProperty.sharedInstance()
  var _savedAmortization: NSArray?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _property.load();
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationItem.title = "Property"
  }
  
  // button action handle
  @IBAction func doSchedule(sender: AnyObject) {
    _savedAmortization = _property.getSavedAmortization();
    if (_savedAmortization != nil) {
      performSegueWithIdentifier("AmortizationTable", sender: _savedAmortization!)
    } else {
      var url = NSString(format: MyStatic.URL_service_tmpl, _property.loanAmt, _property.interestRate, _property.numOfTerms, _property.extra, _property.escrow)
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      var urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
      urlRequest.HTTPMethod = "GET"
      urlRequest.setValue("text/html",forHTTPHeaderField: "accept")
      NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(),
        completionHandler: {(resp: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
          NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(resp: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
              UIApplication.sharedApplication().networkActivityIndicatorVisible = false
              var errMsg: String?
              if error == nil {
                var statusCode = (resp as NSHTTPURLResponse).statusCode
                if(statusCode == 200) {
                  var str = NSString(data: data, encoding: NSUTF8StringEncoding)
                  var parseErr: NSError?
                  var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parseErr) as NSArray?
                  if parseErr == nil {
                    self._property.saveAmortization(json!)
                    self.performSegueWithIdentifier("AmortizationTable", sender: json!)
                    return
                  } else {
                    errMsg = parseErr?.debugDescription
                  }
                } else {
                  errMsg = "HTTP RC: \(statusCode)"
                }
              } else {
                errMsg = error.debugDescription
              }
              
              // show error
              var alert = UIAlertController(title: "Error", message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
              var actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel,
                handler: {action in
                  // do nothing
              })
              alert.addAction(actionCancel)
              self.presentViewController(alert, animated: true, completion: nil)
          })
      })
    }
  }
  
  // implement tableview datasource and delegate
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return NSLocalizedString("mortgage", comment: "")
    } else {
      return NSLocalizedString("operations", comment: "")
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 7
    } else {
      return 2
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("aCell", forIndexPath: indexPath) as UITableViewCell
    var textLabel = cell.textLabel!
    var detailTextLabel = cell.detailTextLabel!
    
    var pos = (indexPath.section, indexPath.row)
    
    switch (pos) {
    case (0, 0):
      textLabel.text = NSLocalizedString("purchasePrice", comment: "")
      detailTextLabel.text = NSString(format: "%.0f", _property.purchasePrice);
    case (0, 1):
      textLabel.text = NSLocalizedString("downPayment", comment: "")
      
      if (_property.purchasePrice > 0) {
        var down = (1 - _property.loanAmt / _property.purchasePrice) * 100.0;
        detailTextLabel.text = NSString(format: "%.0f", down);
        
        if (_property.loanAmt == 0 && down > 0) {
          _property.loanAmt = _property.purchasePrice * (1 - down / 100.0);
        }
      } else {
        detailTextLabel.text = "0";
      }
    case (0, 2):
      textLabel.text = NSLocalizedString("loanAmount", comment: "")
      detailTextLabel.text = NSString(format: "%.2f", _property.loanAmt)
    case (0, 3):
      textLabel.text = NSLocalizedString("interestRate", comment: "")
      detailTextLabel.text = NSString(format: "%.3f", _property.interestRate)
    case (0, 4):
      textLabel.text = NSLocalizedString("mortgageTerm", comment: "")
      detailTextLabel.text = NSString(format: "%d", _property.numOfTerms)
    case (0, 5):
      textLabel.text = NSLocalizedString("escrowAmount", comment: "")
      detailTextLabel.text = NSString(format: "%.0f", _property.escrow)
    case (0, 6):
      textLabel.text = NSLocalizedString("extraPayment", comment: "")
      detailTextLabel.text = NSString(format: "%.0f", _property.escrow);
    case (1, 0):
      textLabel.text = NSLocalizedString("expenses", comment: "")
      detailTextLabel.text = NSString(format: "%.0f", _property.expenses);
    case (1, 1):
      textLabel.text = NSLocalizedString("rent", comment: "")
      detailTextLabel.text = NSString(format: "%.0f", _property.rent);
      
    default:
      break;
    }
    
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier("EditText", sender: indexPath)
  }
  

  // You will often want to do a little preparation before segue navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var identifier = segue.identifier
    if identifier == "EditText" {
      var indexPath = sender as NSIndexPath
      
      var presentedVc =  (segue.destinationViewController as UINavigationController).topViewController as EditTextViewController
      var cell = tableView.cellForRowAtIndexPath(indexPath)!

      presentedVc.tag = indexPath
      presentedVc.header = cell.textLabel!.text!
      presentedVc.text = cell.detailTextLabel!.text!
      presentedVc.delegate = self
    } else { // AmortizationTable segue
      var toFrag = segue.destinationViewController as AmortizationViewController
      toFrag.monthlyTerms = sender as NSArray
    }
  }
  
  // delegate protocol to received data from presented VC
  func onTextEditSaved(vc: EditTextViewController, data: String) {
    self.dismissViewControllerAnimated(true, completion: nil)
    
    switch (vc.tag.section, vc.tag.row) {
    case (0,0):
      _property.purchasePrice = (data as NSString).doubleValue;
      //    String percent = ((NameValuePair) mAdapter.getItem(2)).getValue();
      var indexPath = NSIndexPath(forRow: 0, inSection: 0)
      var percent = tableView.cellForRowAtIndexPath(indexPath)!.detailTextLabel!.text!
      var down = (percent as NSString).doubleValue
      if (_property.purchasePrice > 0 && _property.loanAmt == 0 && down > 0) {
        _property.loanAmt = _property.purchasePrice * (1 - down / 100.0)
      }
      
      break;
    case (0,1):
      var percentage = (data as NSString).doubleValue / 100.0;
      _property.loanAmt = _property.purchasePrice * (1 - percentage);
      break;
    case (0,2):
      _property.loanAmt = (data as NSString).doubleValue;
      break;
    case (0,3):
      _property.interestRate = (data as NSString).doubleValue;
      break;
    case (0,4):
      _property.numOfTerms = (data as NSString).integerValue;
      break;
    case (0,5):
      _property.escrow = (data as NSString).doubleValue;
      break;
    case (0,6):
      _property.extra = (data as NSString).doubleValue;
      break;
    case (1,0):
      _property.expenses = (data as NSString).doubleValue;
      break;
    case (1,1):
      _property.rent = (data as NSString).doubleValue;
      break;
      
    default:
      break;
    }
    tableView.reloadData()
    _property.save();
  }
  
  func onTextEditCanceled(vc: EditTextViewController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
//  private func doAmortization() {
//  }
  
}
