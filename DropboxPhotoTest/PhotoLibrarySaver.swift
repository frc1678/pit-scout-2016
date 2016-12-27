import Photos
/// Is just for saving the photos taken to the camera roll, 1678 did not write this class, we just took it from online somewhere. I had to edit it a bit though. 
class CustomPhotoAlbum {
    
    static let albumName = "Pit Scout Photos 2016"
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
<<<<<<< HEAD
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
=======
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            
            if let firstObject: AnyObject = collection.firstObject {
                return firstObject as! PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
<<<<<<< HEAD
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
=======
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
            }) { success, _ in
                if success {
                    self.assetCollection = fetchAssetCollectionForAlbum()
                }
        }
    }
    
<<<<<<< HEAD
    func saveImage(_ image: UIImage) {
=======
    func saveImage(image: UIImage) {
        
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
<<<<<<< HEAD
        
        
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
            }, completionHandler: { success, error in
                //print("added image to album")
                print(error)
                
        })
    }
    
    
}

=======
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            // let assetPlaceholders = Array(arrayLiteral: )
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
            albumChangeRequest!.addAssets([assetChangeRequest.placeholderForCreatedAsset!])
            }, completionHandler: nil)
    }
    
    
}
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
