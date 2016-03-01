//
//  UIViewExtension.swift
//  DisplayWebP
//
//  Created by Sean Miceli on 2/29/16.
//  Copyright © 2016 smiceli. All rights reserved.
//

import UIKit

extension UIView {
    func constrainToSuperview() -> [NSLayoutConstraint]{
        return [
            constrain(.Top, toView: superview!),
            constrain(.Left, toView: superview!),
            constrain(.Bottom, toView: superview!),
            constrain(.Right, toView: superview!),
        ]
    }

    func constrainToSuperviewMargins() -> [NSLayoutConstraint]{
        return [
            constrain(.Top, toView: superview!, toAttr: .TopMargin),
            constrain(.Left, toView: superview!, toAttr: .LeftMargin),
            constrain(.Bottom, toView: superview!, toAttr: .BottomMargin),
            constrain(.Right, toView: superview!, toAttr: .RightMargin),
        ]
    }

    func constrain(attribute: NSLayoutAttribute, toView: UIView, priority: UILayoutPriority = UILayoutPriorityRequired, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        return constrain(attribute, toView: toView, toAttr: attribute, priority: priority, multiplier: multiplier)
    }

    func constrain(attribute: NSLayoutAttribute, toView: UIView, toAttr: NSLayoutAttribute, priority: UILayoutPriority = UILayoutPriorityRequired, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        if !toView.isDescendantOfView(self) {
            translatesAutoresizingMaskIntoConstraints = false
        }
        if !self.isDescendantOfView(toView) {
            toView.translatesAutoresizingMaskIntoConstraints = false
        }
        let c = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: toView, attribute: toAttr, multiplier: multiplier, constant: 0)
        c.priority = priority
        NSLayoutConstraint.activateConstraints([c])
        return c
    }

    func constrain(attribute: NSLayoutAttribute, _ constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let c = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constant)
        c.priority = priority
        NSLayoutConstraint.activateConstraints([c])
        return c
    }

    func constrain(attributes: [NSLayoutAttribute], toView: UIView, toAttrs: [NSLayoutAttribute], priority: UILayoutPriority = UILayoutPriorityRequired, multiplier: CGFloat = 1.0) -> [NSLayoutConstraint] {
        if attributes.count != toAttrs.count {fatalError()}
        var c = [NSLayoutConstraint]()
        for (index, attr) in attributes.enumerate() {
            c.append(constrain(attr, toView: toView, toAttr: toAttrs[index], priority:  priority, multiplier: multiplier))
        }
        return c
    }

    func constrain(attributes: [NSLayoutAttribute], toView: UIView, priority: UILayoutPriority = UILayoutPriorityRequired, multiplier: CGFloat = 1.0) -> [NSLayoutConstraint] {
        return constrain(attributes, toView: toView, toAttrs: attributes, priority: priority, multiplier: multiplier)
    }
}
