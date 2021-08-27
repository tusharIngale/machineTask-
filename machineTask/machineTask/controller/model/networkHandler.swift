//
//  networkHandler.swift
//  machineTask
//
//  Created by Mac on 27/08/21.
//

import Foundation
class NetworkManager {
    
    //MARK: Global Variables
    
    static let shared = NetworkManager()
    private init() {}
    var venues : [Venue] = []
    var defaultSession = URLSession(configuration: .default)
    var dataTask : URLSessionDataTask?
    var errorMessage = ""
    let urlString = "https://api.foursquare.com/v2/venues/search?ll=40.7484,-73.9857&oauth_token=NPKYZ3WZ1VYMNAZ2FLX1WLECAWSMUVOQZOIDBN53F3LVZBPQ&v=20180616"
    
    //MARK: API Call
    func callVenueAPI(onCompletion: @escaping (Bool, String?) -> Void)  {
        dataTask?.cancel()
        
        guard let url = URL(string: urlString) else { return }
        
        dataTask = defaultSession.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                onCompletion(false, error.localizedDescription)
            } else if let data  = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                var response : [String : Any]?
                
                do {
                    response =  try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                } catch let error as NSError {
                    self.errorMessage = error.localizedDescription
                }
                
                guard let responseDict = response else { return }
                guard let  responseDictionary = responseDict["response"] as? [String : Any]  else { return }
                guard let  venueArray = responseDictionary["venues"] as? Array<Any> else { return }
                
                self.getVenuesFromResponse(responseArray: venueArray)
                DispatchQueue.main.async {
                    onCompletion(true, self.errorMessage)
                }
            }
        })
        dataTask?.resume()
    }
    
    func getVenuesFromResponse(responseArray: Array<Any>) {
        for responseDict in responseArray {
            if let venueDict = responseDict as? [String : Any],
                let id = venueDict["id"] as? String,
                let name = venueDict["name"] as? String {
                venues.append(Venue(id: id, name: name))
            }
        }
    }
    
}
