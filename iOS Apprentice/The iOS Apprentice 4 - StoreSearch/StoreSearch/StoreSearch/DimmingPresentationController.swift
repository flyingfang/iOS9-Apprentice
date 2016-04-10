//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by FLYing on 16/4/5.
//  Copyright © 2016年 FLY. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimingView.frame = containerView!.bounds
        containerView!.insertSubview(dimingView, atIndex: 0)
        dimingView.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                _ in
                self.dimingView.alpha = 1
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        if let transitionCoordinator =
            presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                _ in
                self.dimingView.alpha = 0
                }, completion: nil)
        }
        
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
