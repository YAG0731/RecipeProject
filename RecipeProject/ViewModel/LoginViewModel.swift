import Foundation
import Security

struct Credentials {
    var username: String
    var password: String
}

class LoginViewModel {
    
    private let service = "com.yourapp.recipes"
    private var account: String { return credentials.username }
    
    var credentials: Credentials = Credentials(username: "", password: "")
    
    func authenticateUser() -> Bool {
        // Replace this with actual user validation logic
        let validCredentials = Credentials(username: "user123", password: "pw123")
        return credentials.username == validCredentials.username && credentials.password == validCredentials.password
    }
    
    func saveData() {
        deleteData()
        
        let passwordData = credentials.password.data(using: .utf8)!
        let query = [
            kSecValueData: passwordData,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            print("Error adding item: \(status)")
        }
    }
    
    func getData() -> String? {
        let query = [
            kSecReturnData: true,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data, let password = String(data: data, encoding: .utf8) {
                return password
            }
        }
        
        return nil
    }
    
    func deleteData(){
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        
        if status != errSecSuccess {
            print("Error deleting item: \(status)")
        }
    }
}
