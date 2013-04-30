@Participants = new Meteor.Collection("participants")
@Messages = new Meteor.Collection("messages")

if Meteor.isClient
  Meteor.startup(->
    unless Session.get("myId")
      newParticipantId = Participants.insert(name: '', signed_in: false)
      Session.set("myId", newParticipantId)
  )

  Template.signin.events(
    'click #signin button': (e) ->
      name = $('#signin input').val().trim()
      Meteor.call('signIn', Session.get("myId"), name, (error, result) ->
        Session.set("signedIn", true) unless error?)
      e.preventDefault()
  )

  Template.participants.signedIn = ->
    Participants.find(signed_in: true)

  Template.participants.show = ->
    Session.get("signedIn")

  sendMessage = (e) ->
    e.preventDefault()
    input = $('#chatroom input')
    message = input.val().trim()
    if message.length > 0
      Meteor.call('speak', Session.get("myId"), message, -> input.val(''))

  Template.chatroom.events(
    'click #chatroom button': (e) ->
      sendMessage(e)
    'keydown #chatroom input': (e) ->
      sendMessage(e) if e.keyCode == 13
  )

  Template.chatroom.messages = ->
    Messages.find()

  Template.chatroom.show = ->
    Session.get("signedIn")

  Template.chatroom.rendered = ->
    messageList = $('#chatroom > div')
    table = messageList.find('table')
    messageList.scrollTop(table.height())

if Meteor.isServer
  Meteor.methods(
    signIn: (id, name) ->
      throw new Meteor.Error(500, "Surely you have a name?") unless name?.length > 0
      Participants.update(id, {$set: {name: name, signed_in: true}})
      Messages.insert(text: "#{name} has joined the chat")
    speak: (id, message) ->
      speaker = Participants.findOne(_id: id)
      if speaker?
        Messages.insert(text: "#{speaker.name}: #{message}")
  )
