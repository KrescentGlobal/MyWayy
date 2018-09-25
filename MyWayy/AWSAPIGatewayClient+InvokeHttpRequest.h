//
//  AWSAPIGatewayClient+InvokeHttpRequest.h
//  MyWayy
//
//  Created by SpinDance on 10/18/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

#import <AWSAPIGateway/AWSAPIGateway.h>

@interface AWSAPIGatewayClient ()

- (AWSTask *)invokeHTTPRequest:(NSString *)HTTPMethod
                     URLString:(NSString *)URLString
                pathParameters:(NSDictionary *)pathParameters
               queryParameters:(NSDictionary *)queryParameters
              headerParameters:(NSDictionary *)headerParameters
                          body:(id)body
                 responseClass:(Class)responseClass;

@end
