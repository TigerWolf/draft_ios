
import Foundation
import KeychainAccess

class Player: NSObject {
    
    let id: String
    var firstName: String?
    var lastName: String?
    var name: String?
    var imageURL: String?
    
    var savedImage: UIImage?
    var position: String?
    var drafted: Bool = false
    
    init(id: String, firstName: String, lastName: String, imageURL: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.name = "\(firstName) \(lastName)"
        self.imageURL = imageURL
    }
    
    
}