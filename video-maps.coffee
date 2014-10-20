

youtubeVideos = [
  {_id:"OCQU6M4pPiw", title:"r basic"},
  {_id:"xt1_oXJtB3M", title:"machine learning"},
  {_id:"hIdvjh-O69w", title:"r advanced"},
  {_id:"vteHJEJuNcQ", title:"1234"},
  {_id:"CLq8MlK3oo0", title:"learning r"},
  {_id:"A1IIcZW5UrI", title:"dboy"},
  {_id:"9K3B3OYMtjY", title:"dboy 1234"},
  {_id:"escsixrqG6M", title:"machine gun"},
  
]

@Videos = new Meteor.Collection "ytVideo"

if Meteor.isClient
  Session.setDefault("searchWords",".*")

  Template.videoList.helpers
    # helloTemp: "hello template"
    # helloArray: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    # helloObject: 
    #   name: "test"
    #   data: [{text:"abc"},{text:"fsdfs"},{text:"fsg"}]
    
    # videoList: youtubeVideos

    videoList: -> 
      searchWords = Session.get("searchWords")
      Videos.find {title:{$regex:searchWords,$options:"i"}}, {limit : 20}

  Template.search.events
    "change #searchWords": (e) ->
      e.stopPropagation()
      newSearchWords = $(e.target).val()
      Session.set("searchWords",newSearchWords)
      # console.log e
      # console.log $(e.target).val()

  Template.video.rendered = ->
    # console.log @data._id
    video = Popcorn.youtube("#"+@data._id, 'http://www.youtube.com/embed/'+@data._id)
    


# if Meteor.isServer
#   if Videos.find().count() is 0
#     Videos.insert xx for xx in youtubeVideos