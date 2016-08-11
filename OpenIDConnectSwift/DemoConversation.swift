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
    case Jane    = "053496-4509-289"
    case Rich    = "707-8956784-57"
    case Person    = "707-8956784-56"
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
    case .Jane:
        return "Dr. Jane Doe"
    case .Rich:
        return "Dr. Richard Roe"
    case .Person:
        return activeUser.firstName
    }
}

// Create Unique IDs for avatars
let AvatarIDJohn = "053496-4509-288"
let AvatarIDJane = "053496-4509-289"
let AvatarIDRich = "707-8956784-57"
let AvatarIDPerson = "707-8956784-56"

// Create avatar with Placeholder Image
let AvatarJohn = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(UIImage(named: getPhysicianID("Dr. John Doe")!)!)
let AvatarJane = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(UIImage(named: getPhysicianID("Dr. Jane Doe")!)!)
let AvatarRich = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(UIImage(named: getPhysicianID("Dr. Richard Roe")!)!)
let AvatarPerson = JSQMessagesAvatarImageFactory().avatarImageWithPlaceholder(loadImage())

// Helper Method for getting an avatar for a specific User.
func getAvatar(id: String) -> JSQMessagesAvatarImage{
    let user = User(rawValue: id)!
    
    switch user {
    case .John:
        return AvatarJohn
    case .Jane:
        return AvatarJane
    case .Rich:
        return AvatarRich
    case .Person:
        return AvatarPerson
    }
}


// INFO: Creating Static Demo Data. This is only for the exsample project to show the framework at work.
var conversationsList = [Conversation]()

var conversation = [JSQMessage]()
let message = JSQMessage(senderId: AvatarIDRich, displayName: getName(User.Rich), text: "It looks like Friday, August 12 is not available at 2:30pm. Would 4pm work?")
let message2 = JSQMessage(senderId: AvatarIDPerson, displayName: getName(User.Person), text: "I will move some things on my calendar around and make it work for 4:15pm. Thanks!")
let message3 = JSQMessage(senderId: AvatarIDRich, displayName: getName(User.Rich), text: "You are confirmed for 4pm")

func makeNormalConversation()->[JSQMessage] {
    conversation = [message, message2, message3]
    return conversation
}
