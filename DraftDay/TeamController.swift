//
//  TeamController.swift
//  DraftDay
//
//  Created by Kieran Andrews on 29/02/2016.
//  Copyright © 2016 Kieran Andrews. All rights reserved.
//

import UIKit
import LoginKit
import SVProgressHUD
import SwiftyJSON
import Alamofire

class TeamController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DraftService.getPlayers()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "teamcell")
        self.getPlayers()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(TeamController.getDrafted))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDrafted()
    }
    
    var players: [Player] = []
    var tableData: [Player] = []
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: Move out duplicate code to get data.
    func getDrafted(){
        self.tableData = []
        LoginService.request("drafts/me", .get, nil).validate()
            .responseJSON() { response in
                SVProgressHUD.dismiss()
                
                if response.result.isSuccess {
                    NSLog("success")
                    let json = JSON(response.result.value!)
                    
                    let data = json["data"]

                    for (_,dataItem):(String, JSON) in data {
                        for(player) in self.players {
                            if (player.id == dataItem["player_id"].stringValue){
                                self.tableData.append(player)
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    func getPlayers(){
        LoginService.request("drafts/players", .get, nil).validate()
            .responseJSON() { response in
                SVProgressHUD.dismiss()
                
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    
//                    let lists = json["lists"]
                    for (_,player):(String, JSON) in json {
//                        let player = listItem["player"]
                        let surname = player["surname"].stringValue
                        let givenName = player["givenName"].stringValue
                        let imageURL = player["photoURL"].stringValue
                        let playerID = player["playerId"].stringValue
                        let positions:[String] = player["positions"].arrayValue.map { $0.string!}
                        let player_model: Player = Player(id: playerID, firstName: givenName, lastName: surname, imageURL: imageURL)
                        player_model.position = positions.joined(separator: " ")
                        self.players.append(player_model)
                    }
                    
                    self.players.sort(by: { $0.name! < $1.name! })
                    self.getDrafted()
                }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let player: Player = tableData[indexPath.item]
        
        let reuseIdentifier = "teamcell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        }
        cell!.textLabel?.text = player.name
        cell!.detailTextLabel?.text = player.position
        
        
        cell!.imageView?.image = UIImage(named: "placeholderPerson")
        
        if player.savedImage != nil {
            cell!.imageView!.image = player.savedImage
        } else {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                
                
                let player = self.getPlayer(indexPath)
                let imageURL = player.imageURL!.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                Alamofire.request(imageURL)
                    .responseImage { response in
                        debugPrint(response)
                        
                        print(response.request)
                        print(response.response)
                        debugPrint(response.result)
                        
                        if let image = response.result.value {
                            player.savedImage = image
                            self.updateImage(indexPath, image: image)
                        }
                }
                
            }
        }
        return cell!
    }
    
    func getPlayer(_ indexPath: IndexPath) -> Player{
        var player: Player = Player(id: "1", firstName: "N/A", lastName: "", imageURL: "")
        player = self.tableData[indexPath.item]
        return player
    }
    
    func updateImage(_ indexPath: IndexPath, image: UIImage){
        DispatchQueue.main.async {
            let updateCell = self.tableView.cellForRow(at: indexPath)
            if ((updateCell) != nil) {
                updateCell!.imageView!.image = image
                updateCell!.setNeedsLayout()
            }
        }
        
    }



    
    
}
