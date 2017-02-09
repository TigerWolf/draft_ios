//
//  DraftController.swift
//  DraftDay
//
//  Created by Kieran Andrews on 29/02/2016.
//  Copyright © 2016 Kieran Andrews. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Birdsong

class DraftController: UITabBarController {
    
    let liveDraft = LiveDraftController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.socketRun()
        
//        self.tabBar.frame = CGRectMake(0, 120, self.view.frame.width, self.view.frame.height)
        
        let nav1 = UINavigationController()
//        let liveDraft = LiveDraftController()
        nav1.viewControllers = [liveDraft]
        let nav2 = UINavigationController()
        let team = TeamController()
        nav2.viewControllers = [team]
        let controllers = [nav1, nav2]
        let liveImage = UIImage.fontAwesomeIcon(code: "fa-users", textColor: UIColor.black, size: CGSize(width: 30, height: 30))
//        let liveImage = UIImage.fontAwesomeIconWithName(.Home, textColor: UIColor.blackColor(), size: CGSize(width: 30, height: 30))
        liveDraft.tabBarItem = UITabBarItem(
            title: "Live Draft",
            image: liveImage,
            tag: 1)
//        let teamImage = UIImage.fontAwesomeIconWithName(.Home, textColor: UIColor.blackColor(), size: CGSize(width: 30, height: 30))
        let teamImage = UIImage.fontAwesomeIcon(name: .tasks, textColor: UIColor.black, size: CGSize(width: 30, height: 30))
        team.tabBarItem = UITabBarItem(
            title: "Team",
            image: teamImage,
            tag:2)
        self.viewControllers = controllers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let socket = Socket(url: "http://test.kieranandrews.com.au:4000/socket/websocket")

    
    func onDisconnect(_ error: NSError){
        socket.connect()
    }
    
    func socketRun(){
        //        Socket(url)
        
        NSLog("------------------------------------------------------------- SOCKET")
        
        socket.onConnect = {
            let channel = self.socket.channel("rooms:lobby", payload: ["user": "spartacus"])
//            channel.on("new:msg", callback: { message in
//                self.displayMessage(message)
//            })
            
            channel.on("new:msg", callback: { response in
//                self.lastMessageLabel.text = "Received message: \(response.payload["body"]!)"

                let response_body = response.payload["body"] as! String
                let chat_user = response.payload["user"] ?? " "
                if (response_body == "refresh_list"){
                    NSLog("We need to refresh the list")
                    self.liveDraft.getDraftedStatus()
                }
                
                if ( response_body.hasPrefix("player_picked")){
                    let player_id = response_body.characters.split{$0 == " "}.map(String.init)[1] //(response_body) [1]
                    var player_name = ""
                    for(player) in self.liveDraft.players {
                        if (player.id == player_id){
                            player_name = "\(player.firstName!) \(player.lastName!)"
                        }
                    }
                    
                    let alert = UIAlertController(title: "Player Drafted!", message: "Player \(player_name) was picked by \(chat_user)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                

            })
            
            channel.join().receive("ok", callback: { payload in
                print("Successfully joined: \(channel.topic)")
            })
            
            channel.send("new:msg", payload: ["body": "Hello!"])
                .receive("ok", callback: { response in
                    print("Sent a message!")
                })
                .receive("error", callback: { reason in
                    print("Message didn't send: \(reason)")
                })
            
            // Presence support.
            channel.presence.onStateChange = { newState in
                // newState = dict where key = unique ID, value = array of metas.
                print("New presence state: \(newState)")
            }
            
            channel.presence.onJoin = { id, meta in
                print("Join: user with id \(id) with meta entry: \(meta)")
            }
            
            channel.presence.onLeave = { id, meta in
                print("Leave: user with id \(id) with meta entry: \(meta)")
            }
        }
        // Connect!
        socket.connect()
//        let error = NSError()
        socket.onDisconnect = { error in
            // we need to stop this from spamming
            NSLog("ERROR, DISCONNECTING SOCKET")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.socket.connect()
            }
        }
        
//            onDisconnect(error)
    
    }
    
    
    func displayMessage(_ message: Response){
        NSLog("\(message)")
    }
    
}
