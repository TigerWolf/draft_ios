//
//  DraftServices.swift
//  DraftDay
//
//  Created by Kieran Andrews on 6/03/2016.
//  Copyright © 2016 Kieran Andrews. All rights reserved.
//

import Foundation
import LoginKit
import SwiftyJSON
import SVProgressHUD

let DraftService = DraftServices.sharedInstance

class DraftServices {
    
    static let sharedInstance = DraftServices()
    
    var players: [Player] = []
    
    func getPlayers(){
        
        LoginService.request("drafts/players", .get, nil).validate()
            .responseJSON() { response in
                SVProgressHUD.dismiss()
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    
                    let lists = json["lists"]
                    for (_,listItem):(String, JSON) in lists {
                        let player = listItem["player"]
                        let surname = player["surname"].stringValue
                        let givenName = player["givenName"].stringValue
                        let imageURL = player["photoURL"].stringValue
                        let playerID = player["playerId"].stringValue
                        let player_model: Player = Player(id: playerID, firstName: givenName, lastName: surname, imageURL: imageURL)
                        self.players.append(player_model)
                    }
                    
                    self.players.sort(by: { $0.name! < $1.name! })
                }
        }
        
    }
    
}
