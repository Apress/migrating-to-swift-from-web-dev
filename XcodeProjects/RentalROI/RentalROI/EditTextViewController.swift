//
//  EditTextViewController.swift
//  RentalROI
//
//  Created by Sean on 9/29/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import UIKit

protocol EditTextViewControllerDelegate {
  func onTextEditSaved(vc: EditTextViewController, data: String);
  func onTextEditCanceled(vc: EditTextViewController);
}

class EditTextViewController : UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var mEditText: UITextField!

  var tag: NSIndexPath!
  var header = ""
  var text = ""
  var delegate: EditTextViewControllerDelegate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = self.header
    mEditText.text = self.text
    
    // 1
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "keyboardAppeared:",
      name: UIKeyboardDidShowNotification,object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    showKeyboard()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    hideKeyboard()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    NSNotificationCenter.defaultCenter().removeObserver(self,
      name: UIKeyboardDidShowNotification, object: nil)
  }
  
  @IBAction func doSave(sender: AnyObject) {
    var returnText = self.mEditText.text
    if(delegate != nil) {
      delegate.onTextEditSaved(self, data: returnText)
    }
  }
  
  @IBAction func doCancel(sender: AnyObject) {
    if(delegate != nil) {
      delegate.onTextEditCanceled(self)
    }
  }
  
  func keyboardAppeared(notification: NSNotification) {
    println(">>keyboardAppeared")
    var keyboardInfo = notification.userInfo as NSDictionary!
    var kbFrame = keyboardInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
    var kbFrameRect: CGRect = kbFrame.CGRectValue()
    var keyboardH = min(kbFrameRect.size.width, kbFrameRect.size.height)
    UIView.animateWithDuration(0, animations: { () -> Void in
      
      if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        self.bottomConstraint.constant = self.bottomConstraint.constant + keyboardH/self.bottomConstraint.multiplier
      }
      
      }, completion: {(b) -> Void in
        self.mEditText.selectAll(self);
    })
  }
  
  private func showKeyboard() {
    self.mEditText.becomeFirstResponder()
  }
  
  private func hideKeyboard() {
    self.mEditText.endEditing(true)
  }
  
}
