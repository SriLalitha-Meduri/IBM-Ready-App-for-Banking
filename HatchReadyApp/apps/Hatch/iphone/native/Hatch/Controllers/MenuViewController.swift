/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import QuartzCore

/**
*  Custom UIViewController for the menu
*/
class MenuViewController: UIViewController {
    @IBOutlet weak var logosCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logosCollectionView.backgroundColor = UIColor.clearColor()
        Utils.setUpViewKern(self.view)
    }
    
    /**
    When any menu button is tapped, this function fires. The button's tag is checked to determin which button was tapped and then an appropriate action takes place.
    
    - parameter sender: The button that is tapped
    */
    @IBAction func menuButtonTapped(sender: UIButton) {
        var storyboard : UIStoryboard!
        
        switch sender.tag {
        case 0://Close
            MQALogger.log("Close")
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        case 1://HOME
            MQALogger.log("ACCOUNTS")
            MenuViewController.goToDashboard()

        case 2://GOALS
            MQALogger.log("GOALS")
            MenuViewController.goToGoals()
            
        case 3://PAY BILLS
            MQALogger.log("PAY BILLS")
            
        case 4://DEPOSIT CHECKS
            MQALogger.log("DEPOSIT CHECKS")
            
        case 5://NOTIFICATION CENTER
            MQALogger.log("NOTIFICATION CENTER")
            
        case 6://NEW ACCOUNT
            MQALogger.log("NEW ACCOUNT")
            MenuViewController.goToWatson()
            
        case 7://SETTINGS
            MQALogger.log("SETTINGS")
            MenuViewController.goToSettings()
            
        case 8://CALL SUPPORT
        MQALogger.log("CALL SUPPORT")
            
        case 9://LOG OUT
            MQALogger.log("LOG OUT")
            
            // Show loading screen
            MILLoadViewManager.sharedInstance.show()
            
            let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
            appDelegate.logout()
            
        default:
            MQALogger.log("NO BUTTON")
        }
        
    }
    
    /**
    Class function that will take the app to the Dashboard Storyboard
    */
    class func goToDashboard(businessIndex: Int = 0){
        DashboardDataManager.sharedInstance.businessIndex = businessIndex
        let dashboardStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        transition(dashboardStoryboard)
    }
    
    /**
    Class function that will take the app to the Main Storyboard and the Goals view
    */
    class func goToGoals(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        transition(mainStoryboard)
        WL.sharedInstance().sendActionToJS("changePage", withData: ["route":""]);
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.hybridViewController.fromGoals = true
        appDelegate.hybridViewController.isFirstInstance = true
    }
    
    /**
    Class function that will take the app to the Watson Storyboard
    */
    class func goToWatson(){
        let watsonStoryboard = UIStoryboard(name: "Watson", bundle: nil)
        transition(watsonStoryboard)
    }
    
    /**
    Class function that will take the app to the Main Storyboard and the Settings view
    */
    class func goToSettings(){
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        transition(settingsStoryboard)
    }
    
    class func transition(storyboard: UIStoryboard){
        let viewController = storyboard.instantiateInitialViewController()
        let window = UIApplication.sharedApplication().keyWindow!
        let previousRootViewController = window.rootViewController
        
        window.rootViewController = viewController
        
        // Nasty hack to fix http://stackoverflow.com/questions/26763020/leaking-views-when-changing-rootviewcontroller-inside-transitionwithview
        // The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        let transitionViewClass: AnyClass! = NSClassFromString("UITransitionView")
        for subview in window.subviews {
            if subview.isKindOfClass(transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousRootViewController = previousRootViewController {
            // Allow the view controller to be deallocated
            previousRootViewController.dismissViewControllerAnimated(false) { () -> Void in
                // Remove the root view in case its still showing
                previousRootViewController.view.removeFromSuperview()
            }
        }

    }
}

extension MenuViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DashboardDataManager.sharedInstance.businesses.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuLogoCollectionViewCell", forIndexPath: indexPath) as! MenuLogoCollectionViewCell
        let business = DashboardDataManager.sharedInstance.businesses[indexPath.row]
        
        cell.logoImageView.image = UIImage(named: business.imageName)
        cell.logoImageView.roundImageView()
        
        return cell
    }
}

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        MenuViewController.goToDashboard(indexPath.row)
    }
}

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let numberOfCells: CGFloat = DashboardDataManager.sharedInstance.businesses.count.toFloat.toCGFloat
        let edgeInsets = (self.view.width - (numberOfCells * 50) - ((numberOfCells-1) * 25)) / 2
        
        return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    }
}

