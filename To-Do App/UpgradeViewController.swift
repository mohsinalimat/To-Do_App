//
//  UpgradeViewController.swift
//  ToDo App
//
//  Created by Wismin Effendi on 8/8/17.
//  Copyright © 2017 Wismin Effendi. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol ProductUpgraded: class {
    func productHasUpgradeAction()
}

class UpgradeViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
 
    weak var delegate: ProductUpgraded!

    override func viewDidLoad() {
        view.backgroundColor = UIColor.flatOrangeColorDark()
        upgradeButton.backgroundColor = UIColor.clear
        restoreButton.backgroundColor = UIColor.clear
        upgradeButton.tintColor = UIColor.flatWhiteColorDark()
        restoreButton.tintColor = UIColor.flatWhiteColorDark()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UpgradeManager.sharedInstance.priceForUpgrade { (price) in
            self.priceLabel.text = "\(price)"
            self.upgradeButton.isEnabled = true
            self.restoreButton.isEnabled = true
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeButtonTapped(_ sender: UIButton) {
        UpgradeManager.sharedInstance.upgrade { (succeeded) -> (Void) in
            if succeeded {
                let alertController = UIAlertController(title: NSLocalizedString("Upgraded!", comment: ""),
                                                        message: NSLocalizedString("Thanks for upgrading. You can use the full version.", comment: ""),
                                                        preferredStyle: .alert)
                let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: "alert action"),
                                               style: .default, handler: {[unowned self] (action) in
                    self.delegate?.productHasUpgradeAction()
                    self.dismiss(animated: true, completion: nil)
                })
                
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func restorePurchasesButtonTapped(_ sender: UIButton) {
        UpgradeManager.sharedInstance.restorePurchases { (succeeded) -> (Void) in
            if succeeded {
                let alertController = UIAlertController(title: NSLocalizedString("Restored!", comment: ""),
                                                        message: NSLocalizedString("Your purchases have been restored. You can now use the full version.", comment: ""),
                                                        preferredStyle: .alert)
                let doneAction = UIAlertAction(title: NSLocalizedString("Done", comment: "alert action"),
                                               style: .default, handler: {[unowned self] (action) in
                    self.delegate?.productHasUpgradeAction()
                    self.dismiss(animated: true, completion: nil)
                })
                
                alertController.addAction(doneAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
