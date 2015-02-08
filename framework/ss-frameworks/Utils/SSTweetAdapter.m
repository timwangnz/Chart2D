//
//  TweetAdapter.m
//  JobsExchange
//
//  Created by Anping Wang on 3/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Twitter/Twitter.h>

#import <Accounts/Accounts.h>
#import "SSTweetAdapter.h"
#import "DebugLogger.h"

@implementation SSTweetAdapter

+ (BOOL) canSendTweet
{
    return [SLComposeViewController isAvailableForServiceType :SLServiceTypeTwitter];
}

+ (void)tweet:(NSString *) tweet
{
    if ([self canSendTweet])
    {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
  //      [account requestAccessToAccountsWithType:accountType  withCompletionHandler:^(BOOL granted, NSError *error)
         
         [account requestAccessToAccountsWithType:accountType
                                         options:nil
                                      completion:^(BOOL granted, NSError *error)
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0)
                 {
                     // Keep it simple, use the first account available
                     ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                     
                     // Build a twitter request
                     SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                 requestMethod:SLRequestMethodPOST
                                                                           URL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                                    parameters:nil];
                     
                    // Post the request
                     [postRequest setAccount:acct];
                     
                     // Block handler to manage the response
                     [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          DebugLog(@"Twitter response, HTTP response: %d", (int)[urlResponse statusCode]);
                      }];
                 }
             }
         }];
    }
}

@end
