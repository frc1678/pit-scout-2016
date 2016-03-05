//
//  PhotoUploader.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 2/8/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import SwiftyDropbox
import Firebase
import Haneke

class PhotoManager : NSObject {
    let cache = Shared.dataCache
    var teamNumbers : [Int]
    var mayKeepWorking = true {
        didSet {
            print("mayKeepWorking: \(mayKeepWorking)")
        }
    }
    
    var timer : NSTimer = NSTimer()
    var teamsFirebase : Firebase
    var numberOfPhotosForTeam = [Int: Int]()
    var callbackForPhotoCasheUpdated = { }
    var currentlyNotifyingTeamNumber = 0
    let dropboxClient : DropboxClient
    let photoSaver = CustomPhotoAlbum()
    let dropboxURLBeginning = "https://dl.dropboxusercontent.com/u/63662632/"
    var activeImages = [[String: AnyObject]]()
    
    var syncButton = UIButton()
    
    init(teamsFirebase : Firebase, teamNumbers : [Int], syncButton: UIButton) {
        
        self.syncButton = syncButton
        self.syncButton.setTitle("WAIT", forState: UIControlState.Disabled)
        self.syncButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        self.syncButton.setTitle("Sync", forState: UIControlState.Normal)
        self.teamNumbers = teamNumbers
        self.teamsFirebase = teamsFirebase
        for number in teamNumbers {
            self.numberOfPhotosForTeam[number] = 0
        }
        self.dropboxClient = Dropbox.authorizedClient!
        super.init()
        //self.checkInternetAndSync(self.timer)
    }
    
    
    
    func updatePhotoCache(fileObject: [String: AnyObject], teamNum: Int) {
        self.getPhotosForTeamNum(teamNum) { [unowned self] _ in
            let i = Int((fileObject["name"]?.componentsSeparatedByString(".")[0].componentsSeparatedByString("_")[1])!)
            if i >= self.activeImages.count {
                for _ in self.activeImages.count...i! {
                    self.activeImages.append([String: AnyObject]())
                }
            }
            self.activeImages[i!] = fileObject // We need to actually change the value at the index
            
            self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(self.activeImages), key: "photos\(teamNum)")
            
            if teamNum == self.currentlyNotifyingTeamNumber {
                self.callbackForPhotoCasheUpdated()
            }
        }
    }
    
    
    
    func getSharedURLsForTeam(num: Int, fetched: (NSMutableArray?)->()) {
        if self.mayKeepWorking {
            self.cache.fetch(key: "sharedURLs\(num)").onSuccess { (data) -> () in
                if let urls = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSMutableArray {
                    fetched(urls)
                } else {
                    fetched(nil)
                }
                }.onFailure { (E) -> () in
                    print("Failed to fetch URLS for team \(num)")
            }
        }
    }
    
    func fetchPhotosFromDropbox(var index: Int) {
        
        if index < self.teamNumbers.count {
            self.downloadPhotosForTeamNum(self.teamNumbers[index], success: { [unowned self] () -> () in
                index++
                self.fetchPhotosFromDropbox(index)
                }, index: index)
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.syncButton.enabled = true
                
            })
        }
    }
    
    func downloadPhotosForTeamNum(number: Int, success: ()->(), index: Int) {
        if self.mayKeepWorking {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                if self.isConnectedToNetwork() {
                    self.dropboxClient.files.search(path: "/Public", query: "\(number)_").response({ [unowned self] (response, error) -> Void in
                        if let result = response {
                            self.download(result.matches, number: number, i: 0, success: { () in
                                success()
                            })
                        } else {
                            print("Query Error for team \(number), Error: \(error?.description)")
                            success()
                        }
                    })
                }
            })
        }
        
    }
    
    func download(matches: [Files.SearchMatch], number: Int, var i: Int, success: ()->()) {
        if i < matches.count && i < 6 { // So we don't download too many and fill up memory
            self.downloadPhoto(matches[i], teamNumber: number, success: { [unowned self] () in
                i++
                self.download(matches, number: number, i: i, success: success)
            })
        } else {
            success()
        }
    }
    
    func getPhotosForTeamNum(number: Int, success: ()->()) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if self.mayKeepWorking {
                self.cache.fetch(key: "photos\(number)").onSuccess { [unowned self] (data) -> () in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        if var images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]] {
                            self.activeImages = images
                            images.removeAll()
                            success()
                        }
                    })
                    }.onFailure { [unowned self] (E) -> () in
                        self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject([[String: AnyObject]]()), key: "photos\(number)")
                        self.cache.fetch(key: "photos\(number)").onSuccess { [unowned self] (data) -> () in
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                if var images = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [[String: AnyObject]] {
                                    images.removeAll()
                                    self.activeImages = images
                                    success()
                                }
                            })
                            }.onFailure { (E) -> () in
                                print("Failed to fetch photos for team \(number)")
                                success()
                        }
                }
            }
        //})
    }
    
    
    
    func downloadPhoto(searchMatch: Files.SearchMatch, teamNumber: Int, success: ()->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            if(self.mayKeepWorking) {
                let name = searchMatch.metadata.name
                let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
                    let fileManager = NSFileManager.defaultManager()
                    let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    // generate a unique name for this file in case we've seen it before
                    let UUID = NSUUID().UUIDString
                    let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
                    return directoryURL.URLByAppendingPathComponent(pathComponent)
                }
                
                self.dropboxClient.files.download(path: "/Public/\(name)", destination: destination).response { [unowned self] (response, error) in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        
                        if let (metadata, url) = response {
                            
                            //print("*** Download file ***")
                            var data = NSData(contentsOfURL: url)!
                            self.addFileToLineup(data, fileName: name, teamNumber: teamNumber, shouldUpload: false)
                            data = NSData()
                            //print("Downloaded file url: \(url)")
                            print("Downloaded file name: \(metadata.name)")
                            success()
                        } else {
                            print("Download error for name \(name), error: \(error!)")
                            if self.isConnectedToNetwork() {
                                self.downloadPhoto(searchMatch, teamNumber: teamNumber, success: success)
                            }
                        }
                    })
                }
            }
        })
    }
    
    func uploadPhoto(fileForTeam: [String: AnyObject], teamNumber: Int, index: Int, success: ()->()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            if(self.mayKeepWorking) {
                let name = fileForTeam["name"] as! String
                var data = fileForTeam["data"] as! NSData
                var sharedURL = "Not Uploaded"
                let path = "/Public/\(name)"
                self.dropboxClient.files.upload(path: path, body: data).response { response, error in
                    if let metaData = response {
                        data = NSData()
                        print("*** Upload file: \(metaData) ****")
                        sharedURL = self.makeURLForFileName(name)
                        self.putPhotoLinkToFirebase(sharedURL, teamNumber: teamNumber, selectedImage: false)
                        self.addUrlToList(teamNumber, url: sharedURL, callback: success)
                    } else {
                        data = NSData()
                        self.dropboxClient.files.delete(path: path)
                        print("Upload Error: \(error?.description)")
                        if self.isConnectedToNetwork() {
                            self.uploadPhoto(fileForTeam, teamNumber: teamNumber, index: index, success: success)
                        }
                    }
                }
            }
        })
    }
    
    func getResizedImageDataForImageData(data: NSData) -> NSData {
        var image = UIImage(data: data)
        let newSize: CGSize = CGSize(width: (image?.size.width)! / 2, height: (image?.size.height)! / 2)
        let rect = CGRectMake(0,0, newSize.width, newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        // image is a variable of type UIImage
        image?.drawInRect(rect)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image!)!
    }
    
    func fetchPhotosAndUploadForTeam(ind: Int, successOrFail: ()->()) {
        if self.teamNumbers.count > ind {
            let teamNumber = self.teamNumbers[ind]
            self.getPhotosForTeamNum(teamNumber, success: { [unowned self] in
                print("Fetched Photos for \(teamNumber)")
                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                print("Team \(teamNumber) has \(self.len(self.activeImages)) images.")
                if self.len(self.activeImages) == 0 {
                    successOrFail()
                } else {
                    self.upload(teamNumber, inn: 0, success: successOrFail)
                }
            })
        } else {
            successOrFail()
        }
        
    }
    
    
    
    func len(a: [[String: AnyObject]]) -> Int {
        var l = 0
        for dict in a {
            if dict.keys.count > 0 {
                l++
            }
        }
        return l
    }
    
    func upload(number: Int, var inn: Int, success: ()->()) {
        inn++
        if inn <= len(self.activeImages) && inn < 6 {
            if let shouldUpload = self.activeImages[inn - 1]["shouldUpload"] {
                if shouldUpload as! Bool == true {
                    uploadPhoto(self.activeImages[inn - 1], teamNumber: number, index: inn, success: { [unowned self] in
                        self.upload(number, inn: inn, success: success)
                    })
                }
                else {
                    self.upload(number, inn: inn, success: success)
                }
            } else {
                self.activeImages.removeAtIndex(inn - 1)
                upload(number, inn: inn, success: success)
            }
            
        } else {
            success()
        }
    }
    
    
    func uploadAllPhotos(var currentIndex: Int, callback: ()->()) {
        if(self.isConnectedToNetwork()) {
            
            if currentIndex < self.teamNumbers.count {
                
                fetchPhotosAndUploadForTeam(currentIndex, successOrFail: { [unowned self] in
                    currentIndex++
                    self.uploadAllPhotos(currentIndex, callback: callback)
                })
            } else {
                self.activeImages.removeAll()
                callback()
            }
            
        } else {
            print("Not Connected To Network, cannot upload all photos")
        }
    }
    
    func addUrlToList(teamNumber: Int, url: String, callback: ()->()) {
        self.getSharedURLsForTeam(teamNumber) { [unowned self] (urls) -> () in
            if let nurls = urls {
                nurls.addObject(url)
                self.cache.set(value: NSKeyedArchiver.archivedDataWithRootObject(nurls), key: "sharedURLs\(teamNumber)")
                callback()
            } else {
                print("Could Not get shared urls for \(teamNumber)")
            }
        }
    }
    
    
    func addFileToLineup(var fileData : NSData, fileName : String, teamNumber : Int, shouldUpload : Bool) {
        self.numberOfPhotosForTeam[teamNumber]!++
        while (Double(fileData.length) / pow(2.0, 20.0)) > 10 {
            fileData = self.getResizedImageDataForImageData(fileData)
        }
        let fileDict : [String: AnyObject] = ["name" : fileName, "data" : fileData, "shouldUpload": shouldUpload]
        self.updatePhotoCache(fileDict, teamNum: teamNumber)
        if shouldUpload {
            self.uploadPhoto(fileDict, teamNumber: teamNumber, index: self.numberOfPhotosForTeam[teamNumber]!, success: { })
        }
    }
    
    func isConnectedToNetwork() -> Bool  {
        let url = NSURL(string: "https://www.google.com/")
        let data = NSData(contentsOfURL: url!)
        if (data != nil) {
            return(true)
        }
        return(false)
    }
    
    func checkInternetAndSync(timer: NSTimer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            self.timer.invalidate()
            if(!self.isConnectedToNetwork()) {
                NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkInternetAndSync:", userInfo: nil, repeats: false)
            } else {
                self.sync()
                //NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "uploadAllPhotos:", userInfo: nil, repeats: false)
            }
        })
    }
    
    func putPhotoLinkToFirebase(link: String, teamNumber: Int, selectedImage: Bool) {
        
        let teamFirebase = self.teamsFirebase.childByAppendingPath("\(teamNumber)")
        let currentURLs = teamFirebase?.childByAppendingPath("otherImageUrls")
        currentURLs!.childByAutoId().setValue(link)
        if(selectedImage) {
            teamFirebase?.childByAppendingPath("selectedImageUrl").setValue(link)
        }
        
    }
    
    func sync() {
        self.mayKeepWorking = true
        dispatch_async(dispatch_get_main_queue()) {
            self.syncButton.enabled = false
        }
        self.uploadAllPhotos(0, callback: { [unowned self] in
            self.fetchPhotosFromDropbox(0)
        })
    }
    
    
    func makeURLForTeamNumAndImageIndex(teamNum: Int, imageIndex: Int) -> String {
        return self.dropboxURLBeginning + self.makeFilenameForTeamNumAndIndex(teamNum, imageIndex: imageIndex)
    }
    
    func makeFilenameForTeamNumAndIndex(teamNum: Int, imageIndex: Int) -> String {
        return String(teamNum) + "_" + String(imageIndex) + ".png"
    }
    
    func makeURLForFileName(fileName: String) -> String {
        return self.dropboxURLBeginning + String(fileName)
    }
    
}