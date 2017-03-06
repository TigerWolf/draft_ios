//
//  LiveDraftController.swift
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
import AlamofireImage
import QuartzCore

class LiveDraftController: UITableViewController, UISearchResultsUpdating {
    
    public var players: [Player] = []
    var filteredPlayers: [Player] = []
    let searchController = UISearchController(searchResultsController: nil)
    public var draftStatusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "customcell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(LiveDraftController.getDraftedStatus))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LiveDraftController.logout))
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        SVProgressHUD.show()
        
//        var myView: UIView? = Myview
        let screenSize: CGRect = UIScreen.main.bounds
        var myView = UIView(frame: CGRect(x: 20, y: screenSize.height - 120, width: screenSize.width - 40, height: 50))
        myView.backgroundColor = UIColor.black
        
//        let sampleTextField = UITextField(frame: CGRect(x:20, y:20, width: screenSize.width - 40, height:40)) //myView.frame) //CGRect(x:20, y:100, width:300, height:40))
//        sampleTextField.placeholder = "Last picked was..."
//        sampleTextField.textColor = UIColor.white
//        sampleTextField.font = UIFont.systemFont(ofSize: 15)
//        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
//        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
//        sampleTextField.keyboardType = UIKeyboardType.default
//        sampleTextField.returnKeyType = UIReturnKeyType.done
//        sampleTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
//        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        // TODO: check for
        
        draftStatusLabel = UILabel(frame: CGRect(x:10, y:0, width:300, height:40))
        draftStatusLabel.textColor = UIColor.white
        draftStatusLabel.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        draftStatusLabel.font = UIFont.systemFont(ofSize: 15)
//        draftStatusLabel.layer.cornerRadius = 8
//        draftStatusLabel.layer.masksToBounds = true
        draftStatusLabel.numberOfLines = 0
        draftStatusLabel.text = "Loading..."
//        sampleTextField.delegate = self
//        myView.addSubview(sampleTextField)
        myView.addSubview(draftStatusLabel)
        
        var currentWindow: UIWindow? = UIApplication.shared.keyWindow
//        self.view.addSubview(myView)
        currentWindow?.addSubview(myView)
        
        
        getPlayers()
        
    }
    
    func getPlayers(){
        
        LoginService.request("drafts/players", .get, nil).validate()
            .responseJSON() { response in
                SVProgressHUD.dismiss()
                
                if response.result.isSuccess {
                    NSLog("success")
                    let json = JSON(response.result.value!)
                    
//                    let lists = json["lists"]
                    for (_,player):(String, JSON) in json {
//                        let player = listItem  //["player"]
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
                    self.getDraftedStatus()
                    self.tableView.reloadData()
                }
        }
        
    }
    
    func getDraftedStatus(){
        LoginService.request("drafts", .get, nil).validate()
            .responseJSON() { response in
                SVProgressHUD.dismiss()
                
                if response.result.isSuccess {
                    NSLog("success")
                    let json = JSON(response.result.value!)
                    
                    for(player) in self.players{
                        player.drafted = false
                    }
                    
                    let data = json["data"]
                    for (_,dataItem):(String, JSON) in data {
                        for(player) in self.players {
                            if (player.id == dataItem["player_id"].stringValue){
                                player.drafted = true
                            } else {
                                
                            }
                            
                            
                        }
                        
                    }
                    
//                    self.tableView.reloadData()
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout(){
        LoginService.logoff()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.filteredPlayers.count
        }
        return self.players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var player: Player? = nil
        if searchController.isActive && searchController.searchBar.text != "" {
            player = self.filteredPlayers[indexPath.item]
        } else {
            player = self.players[indexPath.item]
        }
        
        let reuseIdentifier = "customcell"
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as UITableViewCell?
        if (cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        }
        cell!.textLabel?.text = player!.name
        cell!.detailTextLabel?.text = player!.position
        
//        var myImgView = UIImageView(frame: CGRectMake(10, 10, 50, 50))
//        myImgView.setImageWithString:userName color:nil circular:YES];
//            myImgView.set
//        player?.firstName
//        var image = FGInitialCircleImage.circleImage(player?.firstName, lastName: player?.surname, size: initialIcon.frame.size.width, borderWidth: 5, borderColor: UIColor.greenColor(), backgroundColor: UIColor.blueColor(), textColor: UIColor.whiteColor());
        
        if (player?.drafted == true) {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.none
        }
        
        cell!.imageView?.image = UIImage(named: "placeholderPerson")
        
        if player!.savedImage != nil {
            cell!.imageView!.image = player?.savedImage
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
    
    func updateImage(_ indexPath: IndexPath, image: UIImage){
        DispatchQueue.main.async {
            let updateCell = self.tableView.cellForRow(at: indexPath)
            if ((updateCell) != nil) {
                updateCell!.imageView!.image = image
                updateCell!.setNeedsLayout()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let alert = UIAlertController(title: "Draft", message: "Do you want to draft this player?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.draftPlayer(indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlayers = players.filter { player in
            return player.name!.lowercased().contains(searchText.lowercased())
        }
        
        self.tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func getPlayer(_ indexPath: IndexPath) -> Player{
        var player: Player = Player(id: "1", firstName: "N/A", lastName: "", imageURL: "")
        if searchController.isActive && searchController.searchBar.text != "" {
            player = self.filteredPlayers[indexPath.item]
        } else {
            player = self.players[indexPath.item]
        }
        return player
    }
    
    func draftPlayer(_ indexPath: IndexPath){
        let player = getPlayer(indexPath)
        
        SVProgressHUD.show()
        let parameters: [String:AnyObject] = ["player_id": player.id as AnyObject? ?? "" as AnyObject, "position": player.position as AnyObject? ?? "center" as AnyObject]
        var params = [String : [String : AnyObject]]()
        params["draft"] = parameters
        LoginService.request("drafts", .post, params).validate()
            .responseJSON() { response in
                
                
                if response.result.isSuccess {
                    NSLog("posted data")
                    SVProgressHUD.showSuccess(withStatus: "Drafted!")
                    self.getDraftedStatus()
                    self.tableView.reloadData()
                }else{
                    if (response.response!.statusCode == 422){
                        SVProgressHUD.showError(withStatus: "This player has already been drafted.")
                    } else {
                        SVProgressHUD.showError(withStatus: "Fail")
                    }
                }
        }
        
    }
    
}
