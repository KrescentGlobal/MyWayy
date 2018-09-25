//
//  AWSCognitoIdentityUser+SetConfirmationStatus.h
//  MyWayy
//
//  Created by SpinDance on 10/16/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

#import <AWSCognitoIdentityProvider/AWSCognitoIdentityProvider.h>

@interface AWSCognitoIdentityUser ()

- (AWSTask<AWSCognitoIdentityUserSession*>*) setConfirmationStatus: (AWSTask<AWSCognitoIdentityUserSession*>*) task;

@end
