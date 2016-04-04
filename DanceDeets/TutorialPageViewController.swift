//
//  TutorialPageViewController.swift
//  DanceDeets
//
//  Created by LambertMike on 2016/03/29.
//  Copyright © 2016年 david.xiang. All rights reserved.
//

import Foundation

class TutorialPageViewController : UIPageViewController {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [//self.newColoredViewController(0),
                self.newColoredViewController(1),
                self.newColoredViewController(2),
                self.newColoredViewController(3)
        ]
    }()

    private func newColoredViewController(index: Int) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("Tutorial\(index)ViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .Forward,
                               animated: true,
                               completion: nil)
        }
    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}


// MARK: UIPageViewControllerDataSource

extension TutorialPageViewController: UIPageViewControllerDataSource {

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }
}