//
//  DemoConversation.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Modified by Jordan Melberg on 8/10/16
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import JSQMessagesViewController
var activeUser = getActiveUser()

// User Enum to make it easier to work with.
enum User: String {
    case John    = "053496-4509-288"
    case Person  = "707-8956784-56"
}

struct Conversation {
    let firstName: String?
    let lastName: String?
    let preferredName: String?
    let smsNumber: String
    let id: String?
    let latestMessage: String?
    let isRead: Bool
}

// Helper Function to get usernames for a secific User.
func getName(user: User) -> String{
    switch user {
    case .John:
        return "Dr. John Doe"
    case .Person:
        return activeUser.firstName
    }
}

// Create Unique IDs for avatars
let AvatarIDJohn = "053496-4509-288"
let AvatarIDPerson = "707-8956784-56"

// Create avatar with Placeholder Image

let AvatarJohn = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(loadProviderImage("Dr. John Doe"))
let AvatarPerson = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(loadImage())

// Helper Method for getting an avatar for a specific User.
func getAvatar(id: String) -> JSQMessagesAvatarImage{
    let user = User(rawValue: id)!
    
    switch user {
    case .John:
        return AvatarJohn
    case .Person:
        return AvatarPerson
    }
}


// INFO: Creating Static Demo Data. This is only for the exsample project to show the framework at work.
var conversationsList = [Conversation]()

var conversation = [JSQMessage]()
let message = JSQMessage(senderId: AvatarIDJohn, displayName: getName(User.John), text: "It looks like Friday, September 2nd is not available at 2:30pm. Would 4pm work?")
let message2 = JSQMessage(senderId: AvatarIDPerson, displayName: getName(User.Person), text: "I will move some things on my calendar around and make it work for 4:15pm. Thanks!")
let message3 = JSQMessage(senderId: AvatarIDJohn, displayName: getName(User.John), text: "You are confirmed for 4pm")

func makeNormalConversation()->[JSQMessage] {
    conversation = [message, message2, message3]
    return conversation
}
