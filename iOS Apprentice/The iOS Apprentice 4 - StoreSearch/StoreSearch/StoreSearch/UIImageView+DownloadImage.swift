//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by FLYing on 16/4/3.
//  Copyright © 2016年 FLY. All rights reserved.
//

import UIKit

extension UIImageView {
    func  loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        
        // 1
        let downloadTask = session.downloadTaskWithURL( url, completionHandler: {
            [weak self] url , response, error in
            // 2
            if error == nil, let url = url,
            // 4
                data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue(), {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                })
            }
        })
        downloadTask.resume()
        return downloadTask
    }
}
