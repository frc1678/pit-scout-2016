//
//  PitTeamDataSource.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 2/3/16.
//  Copyright © 2016 citruscircuits. All rights reserved.
//

import Foundation
import FirebaseUI
import Firebase

class PitTeamDataSource {
    var firebaseTeamObj : Firebase
    init(teamNumber: Int, firebaseTeamRef: Firebase) {
        self.firebaseTeamObj = firebaseTeamRef
        
    }
}
