//
//  ViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 3/22/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var memosRef: FIRStorageReference!
    var ref: FIRStorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storage = FIRStorage.storage()
        ref = storage.reference()
        memosRef = ref.child("voice_memos")
        
       
        //****************************
        // Uploading file from memory
        //****************************
        
        // Data in memory
        let data = Data()
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = memosRef.put(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            
            print("upload complete \(downloadURL)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func downloadFile(){
        
        // Create a reference to the file we want to download
        let starsRef = storageRef.child("images/stars.jpg")
        
        // Start the download (in this case writing to a file)
        let downloadTask = storageRef.write(toFile: localURL)
        
        // Observe changes in status
        downloadTask.observe(.resume) { snapshot in
            // Download resumed, also fires when the download starts
        }
        
        downloadTask.observe(.pause) { snapshot in
            // Download paused
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
        }
        
        downloadTask.observe(.success) { snapshot in
            // Download completed successfully
        }
        
        // Errors only occur in the "Failure" case
        downloadTask.observe(.failure) { snapshot in
            guard let errorCode = (snapshot.error as? NSError)?.code else {
                return
            }
            guard let error = FIRStorageErrorCode(rawValue: errorCode) else {
                return
            }
            switch (error) {
            case .objectNotFound:
                // File doesn't exist
                break
            case .unauthorized:
                // User doesn't have permission to access file
                break
            case .cancelled:
                // User cancelled the download
                break
                
                /* ... */
                
            case .unknown:
                // Unknown error occurred, inspect the server response
                break
            default:
                // Another error occurred. This is a good place to retry the download.
                break
            }
        }
        
    }*/


}

