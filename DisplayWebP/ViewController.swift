//
//  ViewController.swift
//  DisplayWebP
//
//  Created by Sean Miceli on 2/21/16.
//  Copyright © 2016 smiceli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSURLSessionDelegate {

    // due to Apple's restriction all URL's need to be HTTPS (unless we turn off App Transport Security).
    // URL's snarfed from Google Developer's WebP Gallery
    let urlStrings = [
        "https://www.gstatic.com/webp/gallery/1.jpg",
        "https://www.gstatic.com/webp/gallery/1.webp",
        "https://www.gstatic.com/webp/gallery/2.jpg",
        "https://www.gstatic.com/webp/gallery/2.webp",
        "https://www.gstatic.com/webp/gallery/3.jpg",
        "https://www.gstatic.com/webp/gallery/3.webp",
        "https://www.gstatic.com/webp/gallery/4.jpg",
        "https://www.gstatic.com/webp/gallery/4.webp",
        "https://www.gstatic.com/webp/gallery/5.jpg",
        "https://www.gstatic.com/webp/gallery/5.webp",
    ]


    // MARK: State to refresh collection view cells with

    var urls = [Int: NSURL]()
    var urlIndecies = [NSURL: Int]()
    var images = [Int: UIImage]()
    var errors = [Int: Bool]()
    var errorMessages = [Int: String]()


    // MARK: UIImage/WebP decoding

    private func decodeImageData(data: NSData) -> UIImage? {
        var image = UIImage(data: data)
        if image == nil {
            image = UIImage.imageFromWebPData(data)
        }
        return image
    }


    // MARK: Image Downloading

    private func fetchImage(url: NSURL) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in

            guard let index = self.urlIndecies[url] else {fatalError()}

            if self.checkError(index, data: data, response: response, error: error, url: url) {
                self.errors[index] = true
            }
            else
            if let image = UIImage(data: data!) {
                self.images[index] = image
                self.errors[index] = false
            }
            else {
                if let image = self.decodeImageData(data!) {
                    self.images[index] = image
                    self.errors[index] = false
                }
                else {
                    self.images[index] = nil
                    self.errors[index] = true
                    NSLog("decode error %@", url)
                }
            }

            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
            }
        }
        task.resume()
    }

    
    private func checkError(index: Int, data: NSData?, response: NSURLResponse?, error: NSError?, url: NSURL) -> Bool {

        // error messages not necessarily intended for end users :)
        if data == nil {
            if let err = error {
                errorMessages[index] = "image fetch error: \(url) \(err.description)"
            }
            else if let res = response as? NSHTTPURLResponse {
                errorMessages[index] = "image fetch error: \(res.statusCode) \(url)"
            }
            else {
                errorMessages[index] = "image fetch error \(url)"
            }
            NSLog("%@", errorMessages[index]!)
            return true
        }
        else {
            if let res = response as? NSHTTPURLResponse {
                if res.statusCode != 200 {
                    errorMessages[index] = "image fetch error: \(res.statusCode) \(url)"
                    NSLog("%@", errorMessages[index]!)
                    return true
                }
            }
            return false
        }
    }


    // MARK: Collection View Handling

    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        cv.delegate = self
        cv.dataSource = self
        cv.registerClass(ImageCell.self, forCellWithReuseIdentifier: "cell")
        cv.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)

        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        constrainView(collectionView, toView: view)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlStrings.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ImageCell

        let url = urls[indexPath.item]
        if url == nil {
            guard let url = NSURL(string: urlStrings[indexPath.item]) else {fatalError()}
            urls[indexPath.item] = url
            urlIndecies[url] = indexPath.item
            fetchImage(url)
        }
        cell.image = images[indexPath.item]
        cell.error = errors[indexPath.item] ?? false
        cell.errorMessage = errorMessages[indexPath.item] ?? ""

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/2.0, height: 100)
    }

    private func constrainView(view: UIView, toView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activateConstraints([
            NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: toView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: toView, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: toView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: toView, attribute: .Right, multiplier: 1, constant: 0),
        ])
    }
}

