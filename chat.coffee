@Participants = new Meteor.Collection("participants")
@Messages = new Meteor.Collection("messages")

if Meteor.isClient
  Meteor.startup(->
    newParticipantId = Participants.insert(name: '', signed_in: false)
    Session.set("myId", newParticipantId)
  )

  Template.signin.events(
    'click #signin button': (e) ->
      name = $('#signin input').val().trim()
      Participants.update(Session.get("myId"), {$set: {name: name, signed_in: true}})
      e.preventDefault()
  )

#if Meteor.isServer
