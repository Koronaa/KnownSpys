//
//  NetworkLayer.swift
//  KnownSpys
//
//  Created by Sajith Konara on 3/28/20.
//  Copyright © 2020 Sajith Konara. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkLayer {
    func loadFromServer(finished: @escaping (Data) -> Void)
}


class NetworkLayerIMPL:NetworkLayer{
    
    func loadFromServer(finished: @escaping (Data) -> Void) {
        print("loading data from server")
        AF.request(URL(string: "http://localhost:8080/spies")!).responseJSON { response in
            guard let data = response.data else { return }
            finished(data)
        }
    }
}
