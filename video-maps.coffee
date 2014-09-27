

youtubeVideos = [
  {_id:"OCQU6M4pPiw"},
  {_id:"xt1_oXJtB3M"},
  {_id:"hIdvjh-O69w"},
  {_id:"vteHJEJuNcQ"},
  {_id:"CLq8MlK3oo0"},
  {_id:"A1IIcZW5UrI"},
  {_id:"9K3B3OYMtjY"},
  {_id:"escsixrqG6M"},
]

@Videos = new Meteor.Collection "ytVideos"

if Meteor.isClient
  Template.videoList.helpers
    # helloTemp: "hello template"
    # helloArray: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    # helloObject: 
    #   name: "test"
    #   data: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    
    # videoList: youtubeVideos

    videoList: -> Videos.find {}, {skip:2, limit : 4}

if Meteor.isServer
  if Videos.find().count() is 0
    Videos.insert xx for xx in youtubeVideos