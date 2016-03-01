//
//  ImageCell.swift
//  DisplayWebP
//
//  Created by Sean Miceli on 2/28/16.
//  Copyright © 2016 smiceli. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {

    var image: UIImage? {
        didSet {
            imageView.image = image
            updateState()
        }
    }
    var error = false { didSet { updateState() }}
    var errorMessage = ""

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFit
        return view
    }()

    private lazy var placeholder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGrayColor()
        view.layer.cornerRadius = 7
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cyanColor().CGColor
        return view
    }()

    private lazy var spinny: UIActivityIndicatorView = {
        let spinny = UIActivityIndicatorView(activityIndicatorStyle: .White)
        spinny.hidesWhenStopped = true
        return spinny
    }()

    private lazy var errorView: UIButton = {
        let button = UIButton()
        button.setTitle("⚠️", forState: .Normal)
        button.addTarget(self, action: Selector("errorTapped"), forControlEvents: .TouchUpInside)
        return button
    }()

    private func updateState() {
        switch (image, error) {
        case (nil, false):
            if !spinny.isAnimating() {
                spinny.startAnimating()
            }
            errorView.hidden = true
            imageView.hidden = true
            placeholder.hidden = false

        case (nil, true):
            spinny.stopAnimating()
            errorView.hidden = false
            imageView.hidden = true
            placeholder.hidden = false

        case (_, _):
            spinny.stopAnimating()
            errorView.hidden = true
            imageView.hidden = false
            placeholder.hidden = true
            break
        }
    }

    @objc private func errorTapped() {
        let alert = UIAlertController(title: "Problems Fetching Image", message: errorMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        superview?.willMoveToSuperview(newSuperview)
        if newSuperview == nil || newSuperview == superview { return }

        if contentView.subviews.count == 0 {
            contentView.addSubview(imageView)
            contentView.addSubview(placeholder)
            contentView.addSubview(spinny)
            contentView.addSubview(errorView)

            imageView.constrainToSuperviewMargins()
            placeholder.constrainToSuperviewMargins()
            spinny.constrain([.CenterX, .CenterY], toView: contentView)
            errorView.constrain([.CenterX, .CenterY], toView: contentView)

            updateState()
        }
    }
}
