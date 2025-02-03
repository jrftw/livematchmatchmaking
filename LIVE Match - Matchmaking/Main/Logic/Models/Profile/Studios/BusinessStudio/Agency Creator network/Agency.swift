public struct Agency: Identifiable {
    public let id: String
    public let name: String
    public let founders: String
    public let email: String
    public let phoneNumber: String
    
    // Add an ownerUID to track who can edit
    public let ownerUID: String
    
    public init(
        id: String,
        name: String,
        founders: String,
        email: String,
        phoneNumber: String,
        ownerUID: String
    ) {
        self.id = id
        self.name = name
        self.founders = founders
        self.email = email
        self.phoneNumber = phoneNumber
        self.ownerUID = ownerUID
    }
    
    public static func fromDict(_ dict: [String: Any], docID: String) -> Agency {
        let name = dict["name"] as? String ?? "Unknown Agency"
        let founders = dict["founders"] as? String ?? ""
        let email = dict["email"] as? String ?? ""
        let phone = dict["phoneNumber"] as? String ?? ""
        let owner = dict["ownerUID"] as? String ?? ""
        
        return Agency(
            id: docID,
            name: name,
            founders: founders,
            email: email,
            phoneNumber: phone,
            ownerUID: owner
        )
    }
}
