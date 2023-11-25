// Copyright © 2020 Providence. All rights reserved.

import Foundation

struct DexcareRoute {
    let environment: Environment
    
    var lionTowerBuilder: URLRequestBuilder { return URLRequestBuilder(baseURL: environment.virtualVisitConfiguration.virtualVisitUrl) }
    var fhirBuilder: URLRequestBuilder { return URLRequestBuilder(baseURL: environment.fhirOrchUrl) }
        
    init(environment: Environment) {
        self.environment = environment
    }
}
