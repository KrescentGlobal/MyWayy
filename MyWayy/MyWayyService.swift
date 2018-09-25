//
//  MyWayyService.swift
//  MyWayy
//
//  Created by SpinDance on 9/14/17.
//  Copyright © 2017 SpinDance. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import AWSCognitoIdentityProvider
import AWSAPIGateway
import AWSS3

class MyWayyService: NSObject {
    static let shared = MyWayyService()

    static let RegionType = AWSRegionType.USEast1
    static let IdentityPoolId = "us-east-1:5df8fe3e-3da7-49fc-a0c9-59b1f7487787"
    
    static let ClientId = "1djoc89imurleebfns2ggl9f6i"
    static let UserPoolId = "us-east-1_N78E0dI6O"

    static let AWSPath = URL(string: "https://fjl760q0h3.execute-api.us-east-1.amazonaws.com/dev")!
    static let EndPoint = AWSEndpoint(region: MyWayyService.RegionType, service: .APIGateway, url: MyWayyService.AWSPath)!

    static let S3Bucket = "mywayy-uploads-dev"

    static let ServiceConfigurationKeyForUserPool = "UserPool"
    static let ServiceConfigurationKeyForTransferService = "S3TransferService"

    static let LastUsedUsername = "LastUsedUsername"
    static let AwsErrorMessageKey = "message"
    static let UnknownError = NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Unknown.rawValue, userInfo: nil)
    static let UnknownUserError = NSError(domain: MyWayy.ErrorDomain,
                                          code: MyWayyErrorStates.Unknown.rawValue,
                                          userInfo: [AwsErrorMessageKey: NSLocalizedString("Unknown user.", comment: "")])

    var userPool: AWSCognitoIdentityUserPool?
    var serviceConfiguration: AWSServiceConfiguration?
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var client: AWSAPIGatewayClient?
    var transferManager: AWSS3TransferManager?
    var currentUser: AWSCognitoIdentityUser?

    var profile: Profile?

    override private init() {
        super.init()

        registerUserIdentityPool()
        userPool = acquireUserPool()
        credentialsProvider = buildCredentialsProvider()
        serviceConfiguration = buildServiceConfiguration()

        configureServiceManagerDefaults()
        client = initializeGatewayClient()
        initializeCurrentUser()

        registerTransferManager() 
        transferManager = acquireTransferManager()
    }

    func registerUserIdentityPool() {
        AWSCognitoIdentityUserPool.register(with: buildBasicServiceConfiguration(), userPoolConfiguration: buildUserPoolConfiguration(), forKey: MyWayyService.ServiceConfigurationKeyForUserPool)
    }

    func buildUserPoolConfiguration() -> AWSCognitoIdentityUserPoolConfiguration {
        return AWSCognitoIdentityUserPoolConfiguration(clientId: MyWayyService.ClientId, clientSecret: nil, poolId: MyWayyService.UserPoolId)
    }

    func buildBasicServiceConfiguration() -> AWSServiceConfiguration {
        return AWSServiceConfiguration(region: MyWayyService.RegionType, credentialsProvider: nil)
    }

    func acquireUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: MyWayyService.ServiceConfigurationKeyForUserPool)
    }

    func buildCredentialsProvider() -> AWSCognitoCredentialsProvider {
        return AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: MyWayyService.IdentityPoolId, identityProviderManager: userPool)
    }

    func buildServiceConfiguration() -> AWSServiceConfiguration {
        return AWSServiceConfiguration(region: MyWayyService.RegionType, endpoint: MyWayyService.EndPoint, credentialsProvider: credentialsProvider)
    }

    func configureServiceManagerDefaults() {
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfiguration
    }

    func initializeGatewayClient() -> AWSAPIGatewayClient {
        let client = AWSAPIGatewayClient()
        client.configuration = gatewayClientConfiguration()
        return client
    }

    func gatewayClientConfiguration() -> AWSServiceConfiguration {
        let signer = AWSSignatureV4Signer(credentialsProvider: credentialsProvider, endpoint: MyWayyService.EndPoint)!

        let configuration = serviceConfiguration?.copy() as! AWSServiceConfiguration

        configuration.baseURL = MyWayyService.EndPoint.url
        configuration.requestInterceptors = [AWSNetworkingRequestInterceptor(), signer]

        return configuration
    }

    func initializeCurrentUser() {
        self.currentUser = userPool?.currentUser()
    }

    func registerTransferManager() {
        AWSS3TransferManager.register(with: transferManagerConfiguration(), forKey: MyWayyService.ServiceConfigurationKeyForTransferService)
    }

    func transferManagerConfiguration() -> AWSServiceConfiguration {
        return AWSServiceConfiguration(region: MyWayyService.RegionType, credentialsProvider: credentialsProvider)
    }

    func acquireTransferManager() -> AWSS3TransferManager {
        return AWSS3TransferManager.s3TransferManager(forKey: MyWayyService.ServiceConfigurationKeyForTransferService)
    }

    func cacheDirectory() -> URL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }

    // MARK: AWS

    func signUp(username: String, password: String, attributes: [String:String], _ completionHandler: @escaping (AWSCognitoIdentityUserPoolSignUpResponse?, NSError?) -> Void) {
        userPool?.signUp(username, password: password, userAttributes: convertToAWSAttributes(attributes), validationData: nil).continueWith { (task) in
            DispatchQueue.main.async {
                if let error = task.error {
                    completionHandler(nil, error as NSError)
                } else {
                    if let user = task.result?.user {
                        self.currentUser = user
                        self.setLastUsername(user)
                    }
                    completionHandler(task.result, nil)
                }
            }

            return nil
        }
    }

    func convertToAWSAttributes(_ attributes: [String: String]) -> [AWSCognitoIdentityUserAttributeType] {
        // convert attributes to AWS user identity attributes
        return attributes.reduce([AWSCognitoIdentityUserAttributeType]()) { (result, kvpair: (String, String)) in
            let element = AWSCognitoIdentityUserAttributeType()!
            element.name = kvpair.0
            element.value = kvpair.1
            return result + [element]
        }
    }

    func resendConfirmation(_ handler: @escaping (Bool, NSError?) -> Void) {
        guard let user = currentUser else {
            print("MyWayyService.resendConfirmation.E: currentUser == nil")
            return
        }

        user.resendConfirmationCode().continueWith(block: { (task) -> Any? in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("MyWayyService.resendConfirmation.E: \(error)")
                    handler(false, error as NSError)
                } else {
                    handler(true, nil)
                }
            }

            return nil
        })
    }

    func confirm(username: String, code: String, _ handler: @escaping (AWSCognitoIdentityUserConfirmSignUpResponse?, NSError?) -> Void) {
        currentUser?.confirmSignUp(code).continueWith(block: { (task) -> Any? in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("MyWayyService.confirm.E: \(error)")
                    handler(nil, error as NSError)
                } else {
                    handler(task.result, nil)
                }
            }
            return nil
        })
    }

    func forgotPassword(username: String, _ completionHandler: @escaping (AWSCognitoIdentityUserForgotPasswordResponse?, NSError?) -> Void) {
        guard let user = userPool?.getUser(username) else {
            logError()
            completionHandler(nil, MyWayyService.UnknownUserError)
            return
        }

        user.forgotPassword().continueWith(block: { (task) -> Any? in
            DispatchQueue.main.async {
                if let e = task.error as NSError? {
                    logError(String(describing: e.localizedDescription) + "\n" + String(describing: e.userInfo))
                }
                completionHandler(task.result, task.error as NSError?)
            }
            return nil
        })
    }

    func confirmForgotPassword(username: String, confirmationCode: String, password: String, _ completionHandler: @escaping (AWSCognitoIdentityUserConfirmForgotPasswordResponse?, NSError?) -> Void) {
        guard let user = userPool?.getUser(username) else {
            logError()
            completionHandler(nil, MyWayyService.UnknownUserError)
            return
        }

        user.confirmForgotPassword(confirmationCode, password: password).continueWith(block: { (task) -> Any? in
            DispatchQueue.main.async {
                if let e = task.error as NSError? {
                    logError(String(describing: e.localizedDescription) + "\n" + String(describing: e.userInfo))
                }
                completionHandler(task.result, task.error as NSError?)
            }
        })
    }

    func login(username: String, password: String, _ handler: @escaping (AWSCognitoIdentityUser, AWSCognitoIdentityUserSession?, NSError?) -> Void) {
        if let user = userPool?.getUser(username) {
            user.getSession(username, password: password, validationData: nil).continueWith(block: { (task) -> Any? in
                DispatchQueue.main.async {
                    if let error = task.error {
                        print("MyWayyService.login.E: \(error)")
                        handler(user, nil, error as NSError)
                    } else {
                        self.currentUser = user
                        self.setLastUsername(user)

                        // session created, w/o error, retrieve profile
                        self.loadProfile({ (success, error) in
                            handler(user, task.result, nil)
                        })
                    }
                }

                return nil
            })
        }
    }

    func login(_ handler: @escaping (AWSCognitoIdentityUser, AWSCognitoIdentityUserSession?, NSError?) -> Void) -> Bool {
        if let user = currentUser {
            user.getSession().continueWith(block: { (task) -> Any? in
                DispatchQueue.main.async {
                    user.setConfirmationStatus(task)
                    if let error = task.error {
                        // no session created, error
                        handler(user, nil, error as NSError)
                    } else {
                        // session created, w/o error, retrieve profile
                        self.loadProfile({ (success, error) in
                            handler(user, task.result, nil)
                        })
                    }
                }
                
                return nil
            })

            return true
        } else {
            return false
        }
    }

    func loadProfile(_ handler: @escaping (Bool, NSError?) -> Void) {
        readExpandedProfile({ (success, error) in
            if success && error == nil {
                // local user object is updated by read expanded profile
                handler(true, nil)
            } else {
                // need to insert the profile data
                self.getDetails({ (fields, error) in
                    if error == nil {
                        if self.profile == nil {
                            self.profile = Profile(fields!, updated: true)
                            self.profile?.username = self.currentUser?.username
                            self.profile?.name = self.currentUser?.username
                            self.profile?.totalRoutineMinutes = 0
                            self.profile?.image = "unset"
                        }

                        self.createProfile({ (success, error) in
                            if success {
                                self.loadProfile(handler)
                            } else {
                                handler(success, error)
                            }
                        })
                    } else {
                        // local user object is buggered
                        handler(false, error)
                    }
                })
            }
        })
    }

    func getDetails(_ handler: @escaping (_ fields: [String: Any]?, _ error: NSError?) -> Void) {
        currentUser?.getDetails().continueWith(block: { (task) -> Any? in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("MyWayyService.getDetails.E: \(error)")
                    handler(nil, error as NSError)
                } else {
                    if let response = task.result {
                        var fields = [String: Any]()

                        response.userAttributes?.forEach({ (attribute) in
                            if attribute.name == "phone_number" {
                                // special case, cognito and db differ
                                fields["phoneNumber"] = attribute.value
                            } else {
                                fields[attribute.name!] = attribute.value
                            }
                        })

                        handler(fields, nil)
                    }
                }
            }
            return nil
        })
    }

    func request(_ method: String, _ path: String, _ parameters: [String: Any]?) -> AWSAPIGatewayRequest {
        if method == "GET" {
            return AWSAPIGatewayRequest(httpMethod: method, urlString: path, queryParameters: parameters, headerParameters: nil, httpBody: nil)
        } else {
            return AWSAPIGatewayRequest(httpMethod: method, urlString: path, queryParameters: nil, headerParameters: nil, httpBody: parameters)
        }
    }

    func executeToDictionary(_ request: AWSAPIGatewayRequest, _ handler: @escaping (Bool, [String: Any]?, NSError?) -> Void) {
        withIdentity({ (success, error) in
            guard success else {
                handler(false, nil, error)
                return
            }
            guard self.client != nil else {
                logError("MyWayyService.execute.client.E: nil")
                handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
                return
            }
            self.client?.invoke(request).continueWith(block: { (task) in
                DispatchQueue.main.async {
                    let statusCode = task.result?.statusCode
                    let success = (statusCode != nil && statusCode! >= 200 && statusCode! < 300)
                    let error = task.error as NSError?
                    var responseJson: [String: Any]? = nil
                 
                    // If there is responseData, attempt to parse it.
                    if let d = task.result?.responseData {
                        responseJson = try? JSONSerialization.jsonObject(with: d) as! [String: Any]
                        print(responseJson)
                    }

                    // Fail if an error was reported
                    guard error == nil else {
                        logError(error!.localizedDescription)
                        handler(false, nil, error!)
                        return
                    }

                    // Else if the request succeeded, report the success and the
                    // responseJson, even if it's nil
                    guard !success else {
                        // Success! <- no pun intended here with the '!'
                        handler(true, responseJson, nil)
                        return
                    }

                    // Error occurred - Now look at the reponseJson

                    guard let data = responseJson, let payload_error = data["error"] as? [String: Any] else {
                        // Unknown error; failure occurred, but with no or unexpected data
                        logError("statusCode: \(String(describing: statusCode)); responseJson \(String(describing: responseJson))")
                        handler(false, nil, NSError(domain: MyWayy.ErrorDomain,
                                                    code:    MyWayyErrorStates.Unknown.rawValue,
                                                    userInfo: responseJson))
                        return
                    }

                    logError("\(payload_error)")

                    // Failure occurred, and we have valid error data
                    guard "ValidationError" == payload_error["name"] as? String else {
                        // this may possibly be a good location for creating additional errors
                            handler(false, nil, NSError(domain: MyWayy.ErrorDomain,
                                                    code: MyWayyErrorStates.AWS.rawValue,
                                                    userInfo: data))
                        return
                    }

                    // Validation error
                    handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Validation.rawValue, userInfo: data))
                }
                return nil
            })
        })
    }

    private func executeToArray(_ request: AWSAPIGatewayRequest, _ handler: @escaping (Bool, [Any]?, NSError?) -> Void) {
        withIdentity({ (success, error) in
            guard success else {
                handler(false, nil, error)
                return
            }

            guard self.client != nil else {
                print("MyWayyService.execute.client.E: nil")
                handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
                return
            }

            self.client?.invoke(request).continueWith(block: { (task) in
                DispatchQueue.main.async {
                    let statusCode = task.result?.statusCode
                    let success = (statusCode != nil && statusCode! >= 200 && statusCode! < 300)
                    let data = try? JSONSerialization.jsonObject(with: (task.result?.responseData)!) as! [Any]
                    print(data)

                    if let error = task.error as NSError? {
                        handler(false, nil, error)
                    } else if success {
                        handler(true, data, nil)
                    } else {
                        handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Unknown.rawValue))
                    }
                }
                return nil
            })
        })
    }

    func withIdentity(_ handler: @escaping (Bool, NSError?) -> Void) {
        guard credentialsProvider != nil else {
            print("MyWayyService.identity.credentialsProvider.E: nil")
            handler(false, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
            return
        }

        credentialsProvider?.getIdentityId().continueWith(block: { (task) -> AnyObject? in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("MyWayyService.identity.E: \(error)")
                    handler(false, error as NSError)
                } else {
                    handler(true, nil)
                }
            }
            return nil
        })
    }

    func logout() {
        MyWayyCache.invalidate()

        currentUser = nil

        userPool?.clearLastKnownUser()
        userPool?.clearAll()
        credentialsProvider?.clearCredentials()
        credentialsProvider?.clearKeychain()

        profile = nil
    }

    func setLastUsername(_ user: AWSCognitoIdentityUser?) {
        if user != nil {
            UserDefaults.standard.set(user?.username, forKey: MyWayyService.LastUsedUsername)
        }
    }

    func lastUsername() -> String {
        if let username =  UserDefaults.standard.string(forKey: MyWayyService.LastUsedUsername) {
            return username
        } else {
            return ""
        }
    }

    // MARK: profile

    func createProfile(_ handler: @escaping (Bool, NSError?) -> Void) {
        guard self.profile != nil else {
            print("MyWayyService.createProfile.E: user == nil")
            handler(false, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
            return
        }

        let body = self.profile!.updates()
        
        print(body)
        executeToDictionary(request("POST", "/profiles", body), { (success, response, error) in
            DispatchQueue.main.async {
                handler(success, error)
            }
        })
    }

    func updateProfile(_ handler: @escaping (Bool, NSError?) -> Void) {
        guard profile != nil, profile!.id != nil else {
            handler(false, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
            return
        }

        let id = profile!.id!
        let body = profile!.updates()
        
        executeToDictionary(request("PUT", "/profiles/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if success {
                    self.profile?.clearUpdates()
                }

                handler(success, error)
            }
        })
    }

    private func readExpandedProfile(_ handler: @escaping (Bool, NSError?) -> Void) {
        executeToDictionary(request("GET", "/expanded_profile", nil), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncProfileResponse(data)

                    // cache dependencies
                    let profileDispatchGroup = DispatchGroup()

                    self.profile?.routines.forEach({ (routine) in
                        profileDispatchGroup.enter()

                        self.cacheRoutineTemplate(routine.routineTemplate, {
                            if let routineTemplate = routine.getTemplate() {
                                self.cacheProfile(routineTemplate.profile, {
                                    profileDispatchGroup.leave()
                                })
                            } else {
                                profileDispatchGroup.leave()
                            }
                        })
24                    })

                    profileDispatchGroup.notify(queue: DispatchQueue.main, execute: {
                        handler(success, error)
                    })
                } else {
                    handler(success, error)
                }

            }
        })
    }

    private func syncProfileResponse(_ response: [String: Any]) {
        if profile == nil {
            profile = Profile(response)
        } else {
            profile?.set(fields: response)
        }

        MyWayyCache.profile(profile!)
    }

    func searchProfiles(term: String, limit: Int, offset: Int, _ handler: @escaping (Bool, [Profile]?, NSError?) -> Void) {
        let parameters = [
            "search": term,
            "limit": limit,
            "offset": offset
            ] as [String : Any]
        print(parameters)
        executeToArray(request("GET", "/public_profiles", parameters), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    let profiles: [Profile] = data.map({ (item) in
                        let fields = item as! [String: Any]
                        let profile = MyWayyCache.profile(fields["id"] as? Int, {
                            return Profile(fields)
                        })!
                        profile.set(fields: fields)

                        return profile
                    })

                    handler(true, profiles, nil)
                } else {
                    handler(false, nil, nil) // TODO: error
                }
            }
        })
    }

    private func cacheProfile(_ id: Int?, _ handler: @escaping () -> Void) {
        guard id != nil else {
            print("MyWayyService.cacheProfile.W: id == nil")
            handler()
            return
        }

        if MyWayyCache.profile(id) == nil {
            executeToDictionary(request("GET", "/public_profiles/\(id!)", nil), { (success, response, error) in
                DispatchQueue.main.async {
                    if let fields = response {
                        MyWayyCache.profile(Profile(fields))
                        print(fields)
                    }

                    handler()
                }
            })
        } else {
            handler()
        }
    }

    func currentUserOwns(routine: Routine?) -> Bool? {
        return currentUserOwns(routineTemplate: routine?.getTemplate())
    }

    func currentUserOwns(routineTemplate: RoutineTemplate?) -> Bool? {
        guard
            let currentUserId = profile?.id,
            let ownerId = routineTemplate?.profile
            else {
                return nil
        }

        return currentUserId == ownerId
    }

    // MARK: routine templates

    func createRoutineTemplate(_ template: RoutineTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        let body = template.updates()
            print(body)
        
        executeToDictionary(request("POST", "/routine_templates", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutineTemplate(template, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func updateRoutineTemplate(template: RoutineTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        let id = template.id!
        let body = template.updates()

        executeToDictionary(request("PUT", "/routine_templates/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutineTemplate(template, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func deleteRoutineTemplate(template: RoutineTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        let id = template.id!

        executeToDictionary(request("DELETE", "/routine_templates/\(id)", nil), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    if let success = data["status"] as? Bool {
                        handler(success, error)
                    } else {
                        handler(false, error)
                    }
                } else {
                    handler(false, error)
                }
            }
        })
    }

    func searchRoutineTemplates(term: String, limit: Int, offset: Int, _ handler: @escaping (Bool, [RoutineTemplate]?, NSError?) -> Void) {
        let parameters = [
            "search": term,
            "limit": limit,
            "offset": offset
            ] as [String : Any]

        executeToArray(request("GET", "/public_routine_templates", parameters), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    let profileDispatchGroup = DispatchGroup()

                    let routineTemplates: [RoutineTemplate] = data.map({ (item) in
                        let fields = item as! [String: Any]
                        let routineTemplate = MyWayyCache.routineTemplate(fields["id"] as? Int,{
                            return RoutineTemplate(fields)
                        })!

                        profileDispatchGroup.enter()
                        self.cacheProfile(routineTemplate.profile, {
                            profileDispatchGroup.leave()
                        })

                        return routineTemplate
                    })

                    profileDispatchGroup.notify(queue: DispatchQueue.main, execute: {
                        handler(true, routineTemplates, nil)
                    })
                } else {
                    handler(false, nil, nil) // TODO: error
                }
            }
        })
    }

    func subsribeCurrentUser(to routineTemplate: RoutineTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        guard
            let profile = MyWayyService.shared.profile?.id,
            let templateId = routineTemplate.id,
            let endTime = routineTemplate.endTime,
            let alertStyle = routineTemplate.alertStyle,
            let reminders = routineTemplate.reminder
        else {
            logError()
            handler(false, nil)
            return
        }

        var routineFields = [String: Any]()
        routineFields[Constants.RoutineKeys.profile] = profile
        routineFields[Constants.RoutineKeys.routineTemplate] = templateId
        routineFields[Constants.RoutineKeys.endTime] = endTime
        routineFields[Constants.RoutineKeys.alertStyle] = alertStyle
        routineFields[Constants.RoutineKeys.reminder] = reminders

        // Allow these fields to be nil in routineTemplate
        routineFields[Constants.RoutineKeys.image] = routineTemplate.image
        routineFields[Constants.RoutineKeys.sunday] = routineTemplate.sunday ?? false
        routineFields[Constants.RoutineKeys.monday] = routineTemplate.monday ?? false
        routineFields[Constants.RoutineKeys.tuesday] = routineTemplate.tuesday ?? false
        routineFields[Constants.RoutineKeys.wednesday] = routineTemplate.wednesday ?? false
        routineFields[Constants.RoutineKeys.thursday] = routineTemplate.thursday ?? false
        routineFields[Constants.RoutineKeys.friday] = routineTemplate.friday ?? false
        routineFields[Constants.RoutineKeys.saturday] = routineTemplate.saturday ?? false

        let routine = Routine(routineFields)

        createRoutine(routine) { (success, error) in
            if !success {
                logError(String(describing: error?.getAwsErrorMessage()))
            }

            //var buffer = ""
            //MyWayyService.shared.profile?.toString(&buffer)
            //logDebug("USER: \(buffer)")

            handler(success, error)
        }
    }

    private func syncRoutineTemplate(_ template: RoutineTemplate, fields: [String: Any]) {
        guard profile != nil else {
            print("MyWayyService.syncRoutineTemplate.E profile == nil")
            return
        }

        // update values
        template.set(fields: fields)
        template.clearUpdates()

        MyWayyCache.routineTemplate(template)

        // insert profile routine templates
        let exists = profile?.routineTemplates.reduce(false, { (accumulator, select) in
            return accumulator || template.id == select.id
        })

        if exists == false {
            profile?.routineTemplates.append(template)
        }
    }

    private func cacheRoutineTemplate(_ id: Int?, _ handler: @escaping () -> Void) {
        guard id != nil else {
            print("MyWayyService.cacheRoutineTemplate.W: id == nil")
            handler()
            return
        }

        if MyWayyCache.routineTemplate(id) == nil {
            executeToDictionary(request("GET", "/public_routine_templates/\(id!)", nil), { (success, response, error) in
                DispatchQueue.main.async {
                    if let fields = response {
                        MyWayyCache.routineTemplate(RoutineTemplate(fields))
                    }
                    
                    handler()
                }
            })
        } else {
            handler()
        }
    }

    // MARK: activity templates

    func createActivityTemplate(_ template: ActivityTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        let body = template.updates()
        
        executeToDictionary(request("POST", "/activity_templates", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncActivityTemplate(template, fields: data)
                }
                handler(success, error)
            }
        })
    }
    
    func updateActivityTemplate(template: ActivityTemplate, _ handler: @escaping (Bool, NSError?) -> Void) {
        let id = template.id!
        let body = template.updates()
        
        executeToDictionary(request("PUT", "/activity_templates/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncActivityTemplate(template, fields: data)
                }
                handler(success, error)
            }
        })
    }

    private func syncActivityTemplate(_ template: ActivityTemplate, fields: [String: Any]) {
        guard profile != nil else {
            print("MyWayyService.syncActivityTemplate.E profile == nil")
            return
        }
        
        // update values
        template.set(fields: fields)
        template.clearUpdates()

        // insert profile routine templates
        let exists = profile?.activityTemplates.reduce(false, { (accumulator, select) in
            return accumulator || template.id == select.id
        })
        
        if exists == false {
            profile?.activityTemplates.append(template)
        }
    }

    // MARK: routine template activities

    func createRoutineTemplateActivity(with template: RoutineTemplateActivity,
                                       routineTemplateId: Int,
                                       _ handler: @escaping (Bool, NSError?) -> Void) {
        let body = template.updates()

        executeToDictionary(request("POST", "/routine_templates/\(routineTemplateId)/activities", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutineTemplateActivity(template, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func updateRoutineTemplateActivity(template: RoutineTemplateActivity, _ handler: @escaping (Bool, NSError?) -> Void) {
        let routineTemplate = template.routineTemplate!
        let id = template.id!
        var body = template.updates()

        // Todo: Server does not accept this request with this field included!
        body.removeValue(forKey: "activityTemplate")

        executeToDictionary(request("PUT", "/routine_templates/\(routineTemplate)/activities/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutineTemplateActivity(template, fields: data)
                }
                handler(success, error)
            }
        })
    }

    private func syncRoutineTemplateActivity(_ template: RoutineTemplateActivity, fields: [String: Any]) {
        guard profile != nil else {
            print("MyWayyService.syncRoutineTemplateActivity.E profile == nil")
            return
        }

        template.set(fields: fields)
        template.clearUpdates()

        if let routineTemplate = profile?.getRoutineTemplateById(template.routineTemplate!) {
            let exists = routineTemplate.routineTemplateActivities.reduce(false, { (accumulator, select) in
                return accumulator || template.id == select.id
            })

            if exists == false {
                routineTemplate.routineTemplateActivities.append(template)
                routineTemplate.routineTemplateActivities.sort(by: { $0.displayOrder! > $1.displayOrder! })
            }
        }
    }

    func deleteRoutineTemplateActivity(template: RoutineTemplateActivity, _ handler: @escaping (Bool, NSError?) -> Void) {
        let routineTemplate = template.routineTemplate!
        let id = template.id!

        executeToDictionary(request("DELETE", "/routine_templates/\(routineTemplate)/activities/\(id)", nil), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    if let success = data["status"] as? Bool {
                        handler(success, error)
                    } else {
                        handler(false, error)
                    }
                } else {
                    handler(false, error)
                }
            }
        })
    }

    private func syncRoutineTemplateActivityDeletion(template: RoutineTemplateActivity) {
        guard profile != nil else {
            print("MyWayyService.syncRoutineTemplateActivityDeletion.E profile == nil")
            return
        }

        // insert profile routine templates
        if let routineTemplate = profile?.getRoutineTemplateById(template.routineTemplate!) {
            for (i, t) in routineTemplate.routineTemplateActivities.enumerated() {
                if t.id == template.id {
                    routineTemplate.routineTemplateActivities.remove(at: i)
                    return
                }
            }
        }
    }

    // MARK: routines

    func createRoutine(_ routine: Routine, _ handler: @escaping (Bool, NSError?) -> Void) {
        let body = routine.updates()

        executeToDictionary(request("POST", "/routines", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutine(routine, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func updateRoutine(routine: Routine, _ handler: @escaping (Bool, NSError?) -> Void) {
        let id = routine.id!
        let body = routine.updates()

        executeToDictionary(request("PUT", "/routines/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncRoutine(routine, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func deleteRoutine(withId routineId: Int, profileId: Int, _ handler: @escaping (Bool, NSError?) -> Void) {
 
        let parameters = [
            "userid": profileId,
            "routineid": routineId,
            "action": "DeleteRoutine"
            ] as [String : Any]
        
        print(parameters)
        executeToDictionary(request("GET", "/DeleteActivity", parameters), { (success, response, error) in
            DispatchQueue.main.async {
                
                if !success {
                    logError(String(describing: error?.userInfo))
                }
                handler(success, error)
                }
        })
    }
    
    /*
     
     func deleteRoutine(withId routineId: Int, _ handler: @escaping (Bool, NSError?) -> Void) {
     executeToDictionary(request("DELETE", "/routines/\(routineId)", nil), { (success, response, error) in
     DispatchQueue.main.async {
     if !success {
     logError(String(describing: error?.userInfo))
     }
     handler(success, error)
     }
     })
     }
     
     */

    private func syncRoutine(_ routine: Routine, fields: [String: Any]) {
        guard profile != nil else {
            print("MyWayyService.syncRoutine.E profile == nil")
            return
        }

        routine.set(fields: fields)
        routine.clearUpdates()

        let exists = profile?.routines.reduce(false, { (accumulator, select) in
            return accumulator || routine.id == select.id
        })

        if exists == false {
            profile?.routines.append(routine)
        }
    }

    // MARK: activities

    func createActivity(_ activity: Activity, _ handler: @escaping (Bool, NSError?) -> Void) {
        let routineId = activity.routine!
        let body = activity.updates()

        executeToDictionary(request("POST", "/routines/\(routineId)/activities", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncActivity(activity, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func updateActivity(activity: Activity, _ handler: @escaping (Bool, NSError?) -> Void) {
        let routineId = activity.routine!
        let id = activity.id!
        let body = activity.updates()

        executeToDictionary(request("PUT", "/routines/\(routineId)/activities/\(id)", body), { (success, response, error) in
            DispatchQueue.main.async {
                if let data = response {
                    self.syncActivity(activity, fields: data)
                }
                handler(success, error)
            }
        })
    }

    func deleteActivity(activity: Activity, _ handler: @escaping (Bool, NSError?) -> Void) {
        guard let routineId = activity.routine, let activityId = activity.id else {
            DispatchQueue.main.async {
                handler(false, MyWayyService.UnknownError)
            }
            return
        }
        
        executeToDictionary(request("DELETE", "/routineid/\(routineId)/activityid/\(activityId)/userid/\(profile?.id)", nil)){ (success, response, error) in
            DispatchQueue.main.async {
                let succeeded = success && (response?["status"] as? Bool ?? false)
                if !succeeded {
                    logError(String(describing: error?.localizedDescription) + "\n" + String(describing: error?.userInfo))
                }
                handler(succeeded, error)
            }
        }
    }
    
    func deleteActivityTemplate(activityId: String, profileId : String, _ handler: @escaping (Bool, NSError?) -> Void) {
        
         let profileId = profileId
        let activityId = activityId
      
        let parameters = [
            "userid": profileId,
            "activityid": activityId,
            "action": "DeleteActivity"
            ] as [String : Any]
        
        print(parameters)
        executeToDictionary(request("GET", "/DeleteActivity", parameters), { (success, response, error) in
            DispatchQueue.main.async {
                
                if success {
                 print("success")
                    self.profile?.removeActivityTemplateById(Int(activityId)!)
                }
            }
        })
        
}
    private func syncActivity(_ activity: Activity, fields: [String: Any]) {
        guard profile != nil else {
            print("MyWayyService.syncActivity.E profile == nil")
            return
        }

        activity.set(fields: fields)
        activity.clearUpdates()

        let routineId = activity.routine!

        if let routine = profile?.getRoutineById(routineId) {
            let exists = routine.activities.reduce(false, { (accumulator, select) in
                return accumulator || activity.id == select.id
            })

            if exists == false {
                routine.activities.append(activity)
            }
        }
    }
    
    // MARK: tags

    func tags() -> [String] {
        return MyWayyCache.tags()
    }

    // MARK: AWSS3 Image Management
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    func setProfileImage(_ profile: Profile, image: UIImage, _ handler: @escaping (Bool, NSError?) -> Void) {
        let filename = s3Filename()
       
//        let filename = getTodayString()
        let localUrl = cacheUrl(filename)

        profile.image = filename
        writeToCache(image: image.resizeProfile()!, to: localUrl)

        upload(uploadRequest(localUrl: localUrl), handler)
    }

    func getProfileImage(_ profile: Profile, _ handler: @escaping (Bool, UIImage?, NSError?) -> Void) {
        if profile.image == nil || profile.image == "" {
            handler(false, nil, nil) // TODO: Error?
        } else {
            let localUrl = cacheUrl(profile.image!)
            if let image = loadImage(localUrl) {
                handler(true, image, nil)
            } else {
                let request = downloadRequest(localUrl: localUrl)
                self.download(request, { (success, error) in
                    if success {
                        if let image = self.loadImage(localUrl) {
                            handler(true, image, nil)
                        } else {
                            handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Unknown.rawValue))
                        }
                    } else {
                        handler(false, nil, error)
                    }
                })
            }
        }
    }

    func setRoutineTemplateImage(_ routineTemplate: RoutineTemplate, image: UIImage, _ handler: @escaping (Bool, NSError?) -> Void) {
        let filename = s3Filename()
        let localUrl = cacheUrl(filename)

        routineTemplate.image = filename
        writeToCache(image: image.resizeRoutineTemplate()!, to: localUrl)

        upload(uploadRequest(localUrl: localUrl), handler)
    }

    func getRoutineTemplateImage(_ routineTemplate: RoutineTemplate, _ handler: @escaping (Bool, UIImage?, NSError?) -> Void) {
        if routineTemplate.image == nil || routineTemplate.image == "" {
            handler(false, nil, nil) // TODO: Error?
        } else {
            let localUrl = cacheUrl(routineTemplate.image!)
            if let image = loadImage(localUrl) {
                handler(true, image, nil)
            } else {
                let request = downloadRequest(localUrl: localUrl)
                self.download(request, { (success, error) in
                    if success {
                        if let image = self.loadImage(localUrl) {
                            handler(true, image, nil)
                        } else {
                            handler(false, nil, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Unknown.rawValue))
                        }
                    } else {
                        handler(false, nil, error)
                    }
                })
            }
        }
    }

    private func loadImage(_ localUrl: URL) -> UIImage? {
        if let data = try? Data(contentsOf: localUrl, options: .uncached) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }

    private func s3Filename() -> String {
        return "\(profile!.cognitoIdentityId!)-\(UUID().uuidString)"
    }

    private func cacheUrl(_ name: String) -> URL {
        return cacheDirectory().appendingPathComponent(name)
    }

    private func writeToCache(image: UIImage, to: URL) {
        print("MyWayyService.writeToCache: \(to)")

        let data = UIImageJPEGRepresentation(image, 0.5)!
        try? data.write(to: to, options: .atomicWrite)
    }

    private func uploadRequest(localUrl: URL) -> AWSS3TransferManagerUploadRequest {
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = MyWayyService.S3Bucket
        request.key = localUrl.lastPathComponent
        request.body = localUrl
        return request
    }

    private func upload(_ request: AWSS3TransferManagerUploadRequest, _ handler: @escaping (Bool, NSError?) -> Void) {
        withIdentity({ (success, error) in
            guard success else {
                handler(false, error)
                return
            }

            guard self.transferManager != nil else {
                print("MyWayyService.upload.transferManager.E: nil")
                handler(false, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
                return
            }

            self.transferManager?.upload(request).continueWith(block: { (task) in
                DispatchQueue.main.async {
                    if let error = task.error as NSError? {
                        handler(false, error)
                    } else {
                        handler(true, nil)
                    }
                }
                return nil
            })
        })
    }

    private func downloadRequest(localUrl: URL) -> AWSS3TransferManagerDownloadRequest {
        let request = AWSS3TransferManagerDownloadRequest()!
        request.bucket = MyWayyService.S3Bucket
        request.key = localUrl.lastPathComponent
        request.downloadingFileURL = localUrl
        return request
    }

    private func download(_ request: AWSS3TransferManagerDownloadRequest, _ handler: @escaping (Bool, NSError?) -> Void) {
        withIdentity({ (success, error) in
            guard success else {
                handler(false, error)
                return
            }

            guard self.transferManager != nil else {
                print("MyWayyService.download.transferManager.E: nil")
                handler(false, NSError(domain: MyWayy.ErrorDomain, code: MyWayyErrorStates.Client.rawValue))
                return
            }

            self.transferManager?.download(request).continueWith(block: { (task) in
                DispatchQueue.main.async {
                    if let error = task.error as NSError? {
                        handler(false, error)
                    } else {
                        handler(true, nil)
                    }
                }
                return nil
            })
        })
    }
}
